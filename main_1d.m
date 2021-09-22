clear
clc
close all

% Set parameters.
mu_r = 40;
delta_r = 2;
Sr = 100;
lambda_tv = 0.001;
y = 800;
K = 100;

% Read in test image.
im = im2double(imread('data/step5.png'));
% im = rescale(im);

noise = im(100:200, 100:200);
sigma_e = std(noise(:));

use_chol = 1;

if use_chol == 0
    lambda_tv = lambda_tv*sigma_e^2;
end

% b = rescale(im_blurred_noise); % scale between 0 and 1.
b = im(y,:);

% Initial guess
x = zeros(size(b));

disp(['it: ', num2str(0)])
disp(['  mu_r: ', num2str(mu_r)])
disp(['  delta_r: ', num2str(delta_r)])

for k = 1:K
    
    % Update x
    x = x_update(x, mu_r, delta_r, b, sigma_e, Sr, lambda_tv, use_chol);
    
    x = medfilt1(x);
%     x(x>0.9) = 1;
    
    % Update r
    [mu_r, delta_r] = r_update_1d(x, b, mu_r, delta_r, sigma_e, Sr);
    
    if mod(k, 5)==0
        disp(['it: ', num2str(k)])
        disp(['  mu_r: ', num2str(mu_r)])
        disp(['  delta_r: ', num2str(delta_r)])
    end
end


x0 = zeros(size(im));
lambda_final = 0.01;
final = FISTA_TVsmooth(mu_r, im, lambda_final, x0);

% Show figures.
figure(1); 
imagesc(im); 
title('Original'); 
h = colorbar; 
h.Limits = [0 1];
colormap('gray');

figure(2);
plot(x, 'b');
hold on
plot(im(y,:), 'r')
legend('Estimated', 'True')
title(['\lambda = ' num2str(lambda_tv)]); 
colormap('gray');

figure(3);
imagesc(final); 
title('Deblurred'); 
h = colorbar; 
h.Limits = [0 1];
colormap('gray');