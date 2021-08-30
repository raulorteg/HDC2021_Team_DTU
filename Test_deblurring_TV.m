clear, clc, close all;
addpath('egrssMatlab')

% -----------   TRUE IMAGE   -----------
x = im2double(imread('data/test.jpg'));

% -----------   PARAMETERS   -----------
true_radius = 6;
true_noise_std = 0.015;
mu_r = 10;
delta_r = 0.05;
Sr = 100;
sigma_e = 0.015;
lambda_tv = 10;
use_chol = 1;
alpha = 0.5;
K = 5;

% -----------   BLUR IMAGE   -----------
psf=fspecial('disk',true_radius);
b0 = convb(x,true_radius);
bb = b0 + randn(size(b0))*true_noise_std;
b = rescale(bb);

figure;
subplot(121)
imagesc(x); colormap gray; axis off; 
title('True Image','FontSize',18,'interpret','latex')

subplot(122)
imagesc(b); colormap gray; axis off; 
title('Blurred and Noisy Image','FontSize',18,'interpret','latex')

% -----------   TEST deblurring_TV.m   -----------
close all

tic
[X, mu_r_new] = deblurring_TV(b,mu_r,delta_r,lambda_tv,sigma_e,K,Sr,alpha,use_chol);
toc

%
fprintf('Initial radius:\n')
fprintf('mean: %d\n',mu_r)
fprintf('\nUpdated final radius:\n')
fprintf('mean: %d\n',mu_r_new)

%% --------------   PLOTS   --------------
close all;

figure;
subplot(131)
imagesc(x); colormap gray; axis off; 
h = colorbar; 
h.Limits = [0 1];
title('True Image','FontSize',14,'interpret','latex')

subplot(132)
imagesc(b); colormap gray; axis off; 
h = colorbar; 
h.Limits = [0 1];
title('Blurred and Noisy Image','FontSize',14,'interpret','latex')

subplot(133)
imagesc(X); colormap gray; axis off; 
h = colorbar; 
h.Limits = [0 1];
title(['$\lambda_{TV}$ = ' num2str(lambda_tv)],'FontSize',14,'interpret','latex')
