function main_pipeline(input_folder,output_folder,step)
%input_folder = 'pipeline_test_data';    % function input
%output_folder = 'pipeline_output_data'; % function input

addpath('egrssMatlab')

% Set parameters.
mu_r = 1:20;        % initial mean radius estimates (true ones here)
delta_r = 0.3;
Sr = 100;
lambda_tv = 0.01;
alpha = 0.5;
use_chol = 1;
K = 5;

% Get list of all .tif files in the directory
imagefiles = dir([input_folder '/*.tif']);      
nfiles = length(imagefiles);    % Number of files found

for i = 1:nfiles
    currentfilename = imagefiles(i).name;
    b = im2double(imread([imagefiles(i).folder '\' currentfilename]));
    x = zeros(size(b));   % initial guess just zeros
    
    figure;
    imagesc(b); 
    title('Blurred with noise'); 
    h = colorbar; 
    h.Limits = [0 1];
    colormap('gray');
    drawnow
    
    sigma_e = std2(b(1:20,1:20)); % estimate noise std from small corner patch
    % radius
    if length(currentfilename) == 18
        mu_r = str2double(currentfilename(14));
    else
        mu_r = str2double(currentfilename(14:15));
    end
    
    disp(['it: ', num2str(0)])
    disp(['  mu_r: ', num2str(mu_r)])
    disp(['  delta_r: ', num2str(delta_r)])
    tic
    % main deblurring loop
    for k = 1:K
        % Update x
        [x,~] = x_update(x, mu_r, delta_r, b, sigma_e, Sr, lambda_tv, use_chol);

        x = medfilt2(x);                % median filter to remove noise from regularization
        x = imbilatfilt(x,2*sigma_e,4); % edge enhancement

        % Update psf radius estimate
        [mu_r, delta_r] = r_update(x, b, mu_r, delta_r, sigma_e, Sr, alpha);

        disp(['it: ', num2str(k)])
        disp(['  mu_r: ', num2str(mu_r)])
        disp(['  delta_r: ', num2str(delta_r)])
    end
    toc

    figure;
    imagesc(x); 
    title('Deblurred image'); 
    h = colorbar; 
    h.Limits = [0 1];
    colormap('gray');
    drawnow
    
    % saves image to output folder
    output_file = [output_folder '/' currentfilename(1:end-4) '.png'];
    imwrite(x,output_file)
end

end

