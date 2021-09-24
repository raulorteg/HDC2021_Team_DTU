%function main(input_folder,output_folder,step)
step = 5;
input_folder = ['competition_data_single_sample/step' num2str(step)];    % function input
output_folder = ['competition_data_single_output/step' num2str(step)];    % function input

% Add package
addpath('egrssMatlab')

% Options
save_deblur = 0; %Save output deblurred image?
save_workspace = 0; %Save workspace?
deblur = 1;      % Run deblur? 1: deblur text, 2: deblur PSF, 0: none
use_egrss = 1;   % Use egrss for r_update. If 0 only works on small-scale.
update_x  = 0;   % Update x in r_update iterations?

% Parameters
lambda = 0.01;
sigma_e = 0.034;  % Estimate from step 0.
threshold = 0.7;  % For the cleaning of PSF 0
patch_width  = 200; % Width of patch for radius estimation
patch_height = 200; % Heightof patch for radius estimation
n_iter = 20;      % Number of iterations for r_update
Sr = 200;         % Number of samples for r_update
alpha = 0.1;      % Relaxation parameter in varience est for r_update

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
    
    
    % ===================== Estimate radius =======================
    
    % Cut out patches
    mid = floor(size(PSF_b)/2)+15;
    hpatch_width = patch_width/2;
    hpatch_height = patch_height/2;
    
    CPSF_b     = PSF_b(mid(1)-hpatch_height:mid(1)+hpatch_height, mid(2)-hpatch_width:mid(2)+hpatch_width);
    CPSF_0     = PSF_0(mid(1)-hpatch_height:mid(1)+hpatch_height, mid(2)-hpatch_width:mid(2)+hpatch_width);
    CPSF_clean = PSF_clean(mid(1)-hpatch_height:mid(1)+hpatch_height, mid(2)-hpatch_width:mid(2)+hpatch_width);
    
    figure(6); imshow(CPSF_b); title('Blurred patch')
    figure(7); imshow(CPSF_0); title('Blurred patch (step0)')
    figure(8); imshow(CPSF_clean); title('Cleaned patch (step0)')
    
    % Use r_update
    mu_r = 5;
    delta_r = 1;
    CPSF = CPSF_0;
    for k = 1:n_iter
        
        if update_x == 1
            [CPSF,~] = x_update(CPSF, mu_r, delta_r, CPSF_b, sigma_e, Sr, lambda, 0);
            figure(9); imshow(CPSF); drawnow;
            
            %x = medfilt2(x);                % median filter to remove noise from regularization
            %x = imbilatfilt(x,2*sigma_e,4); % edge enhancement
        end
        
        [mu_r, delta_r] = r_update(CPSF, CPSF_b, mu_r, delta_r, sigma_e, Sr, alpha, use_egrss);
        [mu_r,delta_r,k]
        
    end
    
%     %Use objective function
%     rvec = linspace(5,100,200);
%     objective_f = zeros(size(rvec));
%     for k = 1:length(rvec)
%         k
%         objective_f(k) = norm(A_fun(rvec(k),CPSF_0)+sigma_e*randn(501*501,1)-CPSF_b(:));
%     end
%     figure; plot(rvec,objective_f)
%     
    % Store estimated radius
    r = mu_r;
           
    % ===================== Deblur image ========================
    if deblur==1
        [x,fval] = FISTA_TVsmooth(r,gpuArray(b),lambda,gpuArray(b));    
        x = gather(x);
    elseif deblur == 2
        [x,fval] = FISTA_TVsmooth(r,gpuArray(PSF_b),lambda,gpuArray(PSF_b));    
        x = gather(x);
    else
        x = b; fval = 0;
    end
    
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
    if save_workspace == 1
        save([output_folder '/' currentfilename(1:end-4) '.mat'])
    end
end

