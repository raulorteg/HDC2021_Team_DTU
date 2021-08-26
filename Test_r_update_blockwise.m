% Test of r_update function
clear, clc, close all;

% -----------   TRUE IMAGE   -----------
x = im2double(imread('barbarapart2.tif'));
x = imresize(x,0.2); % makes the image 50% smaller
%x = im2double(imread('CV1.png'));

% -------   BLURRED AND NOISY IMAGE   -------
radius = 2;
psf=fspecial('disk',radius);
b0 = convb(x,radius);
b = round(b0*255)/255 + randn(size(b0))*0.015;

% -----------   TEST r_update.m   -----------
mu_r = 4; delta_r = 0.1; sigma = 0.015; % not sure about sigma
tic

[mu_r_new, delta_r_new] = r_update_blockwise(b,b,mu_r,delta_r,sigma);

toc
fprintf('Initial radius:\n')
fprintf('mean: %d\n',mu_r)
fprintf('standard deviation: %d\n',delta_r)
fprintf('\nUpdated radius:\n')
fprintf('mean: %d\n',mu_r_new)
fprintf('standard deviation: %d\n',delta_r_new)

% --------------   PLOTS   --------------
figure;
subplot(121)
imagesc(x); colormap gray; axis off; 
title('True Image','FontSize',18,'interpret','latex')

subplot(122)
imagesc(b); colormap gray; axis off; 
title('Blurred and Noisy Image','FontSize',18,'interpret','latex')
