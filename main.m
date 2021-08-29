clear
clc
close all

% Set parameters.
true_radius = 6;
true_noise_std = 0.015;
mu_r = 10;
delta_r = 0.05;
Sr = 100;
sigma_e = 0.015;
lambda_tv = 10;

use_chol = 1;
K = 5;

% Read in test image.
im = im2double(imread('data/test.jpg'));

% Blur and add noise.
im_blurred =  convb(im, true_radius);
im_blurred_noise = im_blurred + randn(size(im_blurred))*true_noise_std;
x = rescale(im_blurred_noise); % scale between 0 and 1.
b = x;

disp(['it: ', num2str(0)])
disp(['  mu_r: ', num2str(mu_r)])
disp(['  delta_r: ', num2str(delta_r)])

for k = 1:K
    % Update r
    [mu_r, delta_r] = r_update_blockwise(x, b, mu_r, delta_r, sigma_e, Sr);
    % Update x
    [x, f_vec] = x_update(x, mu_r, delta_r, b, sigma_e, Sr, lambda_tv, use_chol);
    
    disp(['it: ', num2str(k)])
    disp(['  mu_r: ', num2str(mu_r)])
    disp(['  delta_r: ', num2str(delta_r)])
end

% Show figures.
figure(1); 
imagesc(im); title('Original'); 
h = colorbar; 
h.Limits = [0 1];
colormap('gray');

figure(2); 
imagesc(im_blurred_noise); 
title('Blurred with noise'); 
h = colorbar; 
h.Limits = [0 1];
colormap('gray');

figure(3)
imagesc(x); 
title(['\lambda = ' num2str(lambda_tv)]); 
h = colorbar; 
h.Limits = [0 1];
colormap('gray');
