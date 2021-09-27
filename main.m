%function main(input_folder,output_folder,step)
clear; close all force; clc;
step = 5;
input_folder = ['competition_data_single_sample/step' num2str(step)];    % function input
output_folder = ['competition_data_single_output/step' num2str(step)];    % function input

% Add package
addpath('egrssMatlab')

% Options
save_deblur = 0;    %Save output deblurred image?
save_workspace = 0; %Save workspace?
use_egrss = 1;   % Use egrss package for r_update? If 0 only works on small-scale.
use_gpu = 1;  %Use gpu for faster computations?

% Initial guesses on radius
%r0 = [0,8,16,28,40,50,57,63,68,74,79,85,90,96,101,107,112,118,123,129];
r0 = [0,8,16,28,40,38,57,63,68,74,79,85,90,96,101,107,112,118,123,129];
dr0 = [0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3];
mu_r0 = r0(step+1); %Initial radius
delta_r0 = dr0(step+1);     %Initial variance

% Other Parameters
lambda_deblur = 0.01;    %Regularization parameter for final deblur
lambda_restimate = 0.001;%Regularization parameter for r update
%sigma_e = 0.034;  % Estimate of noise standard deviation
patch_width  = 200; % Width of patch for radius estimation
patch_height = 200; % Heightof patch for radius estimation
n_iter = 100;      % Number of iterations for r_update
Sr = 200;         % Number of samples for r_update
Sx = 100;           % Number of samples for x_update
alpha = 0.0;      % Relaxation parameter in varience est for r_update
mid_shift = 15; %Shift center of image to better align letters?


% =============== Algorithm start ===============

% Get list of all .tif files in the directory
imagefiles = dir([input_folder '/*.tif']);
nfiles = length(imagefiles);    % Number of files found

% Loop over all images in folder and deblur
for i = 1:nfiles
    
    %Load current image
    currentfilename = imagefiles(i).name;
    b = im2double(imread([imagefiles(i).folder '\' currentfilename]));
    
    % Estimate noise standard deviation
    sigma_e = std2(b(1:50,1:50)); % estimate noise std from small corner patch
    
    % ==== Prepare patches =====
    mid = floor(size(b)/2)+mid_shift;
    hpatch_width = patch_width/2;
    hpatch_height = patch_height/2;
    b_patch     = b(mid(1)-hpatch_height:mid(1)+hpatch_height, mid(2)-hpatch_width:mid(2)+hpatch_width);
    figure(1); imshow(b_patch); title('Blurred image (patch)'); drawnow;
    
    % Initial guess
    x = zeros(size(b_patch));
    mu_r = mu_r0;
    delta_r = delta_r0;
    [mu_r,delta_r,0]
    
    % ==== Iteration for r estimation =====
    for k = 1:n_iter
        
        % Update x
        x = x_update(x, mu_r, delta_r, b_patch, sigma_e, Sx, lambda_restimate, 1);
        figure(2); imshow(x); title('Current deblurred patch'); drawnow;
        
        x_old = x;
        % Filter x
        x = medfilt2(x, [5,5],'zeros');                % median filter to remove noise from regularization
        %x = imbilatfilt(x,2*sigma_e,4); % edge enhancement
        %x(x>=0.75)=1;
        %x(x<0.75)=0;
        %x = imsharpen(x);
        %x = imsharpen(x,'Radius',15,'Amount',1.5);
        figure(3); imshow(x); title('Current deblurred patch (filtered)'); drawnow;
        
        % Update r
        [mu_r, delta_r] = r_update(x, b_patch, mu_r, delta_r, sigma_e, Sr, alpha, use_egrss);
        
        % Show result
        [mu_r,delta_r,k]
        
    end
 
    if use_gpu == 1
        x = gpuArray(zeros(size(b)));
        b = gpuArray(b);
    end
    
    % ==== Deblur with initial guess ====

    x_initial = x_update(x, mu_r0, delta_r0, b, sigma_e, 0, lambda_deblur, 0);
    figure(4); imshow(x_initial); title("Deblur with initial guess"); drawnow;
    
    % ==== Deblur with estimate ====
    x_estimate = x_update(x, mu_r, delta_r, b, sigma_e, 0, lambda_deblur, 0);
    figure(5); imshow(x_estimate); title("Deblur with estimate"); drawnow;
    
   
    % Save to file
    if save_deblur == 1
        % saves image to output folder
        output_file = [output_folder '/' currentfilename(1:end-4) '.png'];
        imwrite(x_estimate,output_file)
    end
    if save_workspace == 1
        save([output_folder '/' currentfilename(1:end-4) '.mat'])
    end
end
%%
   
if use_gpu == 1
    x = gpuArray(zeros(size(b)));
    b = gpuArray(b);
end
% ==== Manual? ====
x_manual = x_update(x, 35, 0.3, b, sigma_e, 0, lambda_deblur, 0);
figure(6); imshow(x_manual); title("Deblur with manual estimate"); drawnow;
figure(7); imshow(b); title('Blurred image'); drawnow;
