clear
clc
close all

% Set parameters.
true_radius = 3;
true_noise_std = 0.015;
mu_r = 2.8;
delta_r = 0.15;
Sr = 100;
sigma_e = 0.015;
lambda_tv = 0.1;

use_chol = 1;
K = 5;

% Read in test image.
im = im2double(imread('data/test.jpg'));
im = imresize(im, 0.5); % DOWNSCALE IMAGE BEFORE USE FOR FASTER COMPUTATION IN TESTS

% Blur and add noise.
im_blurred =  convb(im, true_radius);
im_blurred_noise = im_blurred + randn(size(im_blurred))*true_noise_std;
x = rescale(im_blurred_noise); % scale between 0 and 1.
b = x;

disp(['it: ', num2str(0)])
disp(['  mu_r: ', num2str(mu_r)])
disp(['  delta_r: ', num2str(delta_r)])

obj_hist = zeros(1,K);
mu_r_hist = zeros(1,K+1); mu_r_hist(1) = mu_r;
delta_r_hist = zeros(1,K+1); delta_r_hist(1) = delta_r;
for k = 1:K
    % Update x
    [x, f_vec] = x_update(x, mu_r, delta_r, b, sigma_e, Sr, lambda_tv, use_chol);
    
    % Update r
    [mu_r, delta_r] = r_update_blockwise(x, b, mu_r, delta_r, sigma_e, Sr);
    
    disp(['it: ', num2str(k)])
    disp(['  mu_r: ', num2str(mu_r)])
    disp(['  delta_r: ', num2str(delta_r)])
    disp(['  obj. fun: ', num2str(f_vec(end))])
    obj_hist(k) = f_vec(end);
    mu_r_hist(k+1) = mu_r;
    delta_r_hist(k+1) = delta_r;
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

figure(3);
imagesc(x); 
title(['\lambda = ' num2str(lambda_tv)]); 
h = colorbar; 
h.Limits = [0 1];
colormap('gray');

figure(4);
plot(1:K,obj_hist);
title('Objective function');
xlabel('iteration');

r_bounds = zeros(2,K+1);
for k = 1:(K+1)
    r_bounds(:,k) = norminv([0.025 0.975],mu_r_hist(k),delta_r_hist(k));
end
figure(5);
plot(0:K,mu_r_hist,'b');
hold on
plot(0:K,r_bounds,'b--');
plot([0,K],[true_radius,true_radius],':k');
ylim([min(r_bounds,[],'all')*0.95,max(r_bounds,[],'all')*1.05]);
title('95% confidence interval of radius')
xlabel('iteration');