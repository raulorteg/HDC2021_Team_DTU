%% load competition data
clear, close all;
addpath('egrssMatlab')

%profile on 

steps = 0:19;
sample = '001'; % '001' to '100'
font = 'verdana';   
n = 14;

% Set parameters.
mu_r = 2;
delta_r = 0.1;
Sr = 100;
lambda_tv = 0.001;
alpha = 0.5;
use_chol = 1;
K = 1;
mu_r_hist = zeros(1,K+1); mu_r_hist(1) = mu_r;
delta_r_hist = zeros(1,K+1); delta_r_hist(1) = delta_r;

for i = 5
    step = num2str(steps(i));
    folder = ['C:\Users\Rainow slayer\OneDrive\Documents\Skole\DTU\HDC 2021 - Image ' ...
        'deblurring project course\HDC 2021 Data\HDC2021_step' step '\step' step '\' font '\'];
    if strcmp(font,'verdana')
        bfile = ['CAM02\focusStep_' step '_' font 'Ref_size_30_sample_0' sample '.tif']; % blurred 
        xfile = ['CAM02\focusStep_' step '_' font 'Ref_size_30_sample_0' sample '.tif']; % exact 
    elseif strcmp(font,'times')
        bfile = ['CAM02\focusStep_' step '_' font 'R_size_30_sample_0' sample '.tif']; % blurred 
        xfile = ['CAM02\focusStep_' step '_' font 'R_size_30_sample_0' sample '.tif']; % exact
    end
    
    re = 0.4;
    b = imresize(im2double(imread([folder bfile])),re);
%    x = imresize(im2double(imread([folder xfile]),re));
    x = zeros(size(b)); 

    sigma_e = std2(b(1:20,1:20)); % estimate noise std from small corner patch
    
    disp(['it: ', num2str(0)])
    disp(['  mu_r: ', num2str(mu_r)])
    disp(['  delta_r: ', num2str(delta_r)])
    
    for k = 1:K
         tic
         % Update x
         [x,f_vec] = x_update(x, mu_r, delta_r, b, sigma_e, Sr, lambda_tv, use_chol);
         toc
         
        tic
        % Update r
        [mu_r, delta_r] = r_updatee(x, b, mu_r, delta_r, sigma_e, Sr, alpha);
        toc
        
        disp(['it: ', num2str(k)])
        disp(['  mu_r: ', num2str(mu_r)])
        disp(['  delta_r: ', num2str(delta_r)])

        mu_r_hist(k+1) = mu_r;
        delta_r_hist(k+1) = delta_r;
    end
    
end

%profile viewer                   % information about execution time etc.
%x = medfilt2(x);                % median filter to remove noise
%x = imbilatfilt(x,2*sigma_e,1); % edge enhancement
%%
figure;
imagesc(b); 
title('Blurred image'); 
h = colorbar; 
h.Limits = [0 1];
colormap('gray');
    
figure;
imagesc(x); 
title('Deblurred image'); 
h = colorbar; 
h.Limits = [0 1];
colormap('gray');


