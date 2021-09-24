%function main(input_folder,output_folder,step)
step = 0;
input_folder = ['competition_data_single_sample/step' num2str(step)];    % function input
output_folder = ['competition_data_single_output/step' num2str(step)];    % function input

% Add package
addpath('egrssMatlab')

% Options
save_deblur = 0; %Save output deblurred image?
save_radius = 0; %Save output radius?

% Parameters
lambda = 0.01;
sigma_e = 0.034; % Estimate from step 0.
threshold = 0.7; % For the cleaning of PSF 0

% Load PSFs
PSF_0 = im2double(imread(['PSF/focusStep_' num2str(0) '_PSF.tif']));
PSF_b = im2double(imread(['PSF/focusStep_' num2str(step) '_PSF.tif']));

% Try clean up PSF 0 with simple thresholding
PSF_clean = PSF_0;
PSF_clean(PSF_0<threshold) = 0;
PSF_clean(PSF_0>=threshold) = 1;

% Get list of all .tif files in the directory
imagefiles = dir([input_folder '/*.tif']);      
nfiles = length(imagefiles);    % Number of files found

% Loop over all images in folder and deblur
for i = 1:nfiles
    
    %Load current image
    currentfilename = imagefiles(i).name;
    b = im2double(imread([imagefiles(i).folder '\' currentfilename]));
    
    % Estimate noise standard deviation
    %sigma_e = std2(b(1:100,1:100)) % estimate noise std from small corner patch
    
    figure(1);
    imagesc(b); 
    title('Blurred with noise'); 
    h = colorbar; 
    h.Limits = [0 1];
    colormap('gray');
    drawnow
    
    
    % Estimate radius
    r = 37;
    
       
    % Deblur image
    [x,fval] = FISTA_TVsmooth(r,gpuArray(b),lambda,gpuArray(b));    
    x = gather(x);
    
    figure(2);
    imagesc(x); 
    title('Deblurred image'); 
    h = colorbar; 
    h.Limits = [0 1];
    colormap('gray');
    drawnow
    
    x_filtered1 = medfilt2(x);                % median filter to remove noise from regularization
    x_filtered2 = imbilatfilt(x_filtered1,2*sigma_e,4); % edge enhancement
    
    figure(3);
    imagesc(x_filtered1); 
    title('First filtering'); 
    h = colorbar; 
    h.Limits = [0 1];
    colormap('gray');
    drawnow
    
    figure(4);
    imagesc(x_filtered2); 
    title('Second filtering'); 
    h = colorbar; 
    h.Limits = [0 1];
    colormap('gray');
    drawnow
    
    figure(5);
    plot(fval);
    title("Objective function of deblur using FISTA")
    drawnow
    
    % Save to file
    if save_deblur == 1
        % saves image to output folder
        output_file = [output_folder '/' currentfilename(1:end-4) '.png'];
        imwrite(x,output_file)
    end
    if save_radius == 1
        save([output_folder '/' currentfilename(1:end-4) '.mat'])
    end
end