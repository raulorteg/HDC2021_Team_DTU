clear
clc
close all

% Set parameters.
true_radius = 4;
true_noise_std = 0.015;
mu_r = 3.9;
delta_r = 0.5;
Sr = 100;
sigma_e = 0.015;
lambda_tv = 0.01;
y = 30;

use_chol = 0;

if use_chol == 0
    lambda_tv = lambda_tv*true_noise_std^2;
end

K = 100;

% Read in test image.
im = im2double(imread('data/test.jpg'));
im = imresize(im, 1); % DOWNSCALE IMAGE BEFORE USE FOR FASTER COMPUTATION IN TESTS

% Blur and add noise.
im_blurred =  convb(im, true_radius);
im_blurred_noise = im_blurred + randn(size(im_blurred))*true_noise_std;
b = rescale(im_blurred_noise); % scale between 0 and 1.
b = b(y,:);


% Initial guess
x = ones(size(b));

disp(['it: ', num2str(0)])
disp(['  mu_r: ', num2str(mu_r)])
disp(['  delta_r: ', num2str(delta_r)])

for k = 1:K
    
    % Update x
    [x,f_vec] = x_update(x, mu_r, delta_r, b, sigma_e, Sr, lambda_tv, use_chol);
    
    % Update r
    [mu_r, delta_r] = r_update(x, b, mu_r, delta_r, sigma_e, Sr);
    
    if mod(k, 10)==0
        disp(['it: ', num2str(k)])
        disp(['  mu_r: ', num2str(mu_r)])
        disp(['  delta_r: ', num2str(delta_r)])
    end
end

[final, f_vec] = x_update(zeros(size(im_blurred_noise)), mu_r, delta_r, im_blurred_noise, sigma_e, Sr, lambda_tv, use_chol);

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
plot(x, 'b');
hold on
plot(im(y,:), 'r')
legend('Estimated', 'True')
title(['\lambda = ' num2str(lambda_tv)]); 
colormap('gray');

figure(4);
imagesc(final); 
title(['\lambda = ' num2str(lambda_tv)]); 
h = colorbar; 
h.Limits = [0 1];
colormap('gray');