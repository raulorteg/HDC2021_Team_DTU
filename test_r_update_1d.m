% Test of r_update function
clear, clc, close all;

% -----------   TRUE IMAGE   -----------
x = im2double(imread('data/test.jpg'));

% ----------   PARAMETERS   -----------
radius = 4;
sigma = 0.015; % measurement error
mu_r = 3.5; delta_r = 0.5;
Sr = 100;

% -------   BLURRED AND NOISY IMAGE   -------
b0 = convb(x,radius);
b = round(b0*255)/255 + randn(size(b0))*sigma;
b(b<0) = 0;


x = x(30,:);
b = b(30,:);
b1d = convb_1d(x,radius);
b1d = round(b1d*255)/255 + randn(size(b1d))*sigma;
b1d(b1d<0) = 0;

% -----------   TEST r_update_1d.m   -----------
tic

[mu_r_new, delta_r_new] = r_update_1d(x,b,mu_r,delta_r,sigma,Sr);

toc
fprintf('Initial radius:\n')
fprintf('mean: %d\n',mu_r)
fprintf('standard deviation: %d\n',delta_r)
fprintf('\nUpdated radius:\n')
fprintf('mean: %d\n',mu_r_new)
fprintf('standard deviation: %d\n',delta_r_new)

% --------------   PLOTS   --------------
figure;
subplot(131)
plot(x); ylim([0,1]);% axis off; 
title('True Image','FontSize',18,'interpret','latex')

subplot(132)
plot(b); ylim([0,1]);% axis off; 
title('2d blur','FontSize',18,'interpret','latex')

subplot(133)
plot(b1d); ylim([0,1]);% axis off; 
title('1d blur','FontSize',18,'interpret','latex')

