%% load competition data
clear, clc, close all;
addpath('egrssMatlab')

step = '3'; % '0' to '19'
sample = '001'; % '001' to '100'
font = 'times';   
folder = ['C:\Users\Rainow Slayer\OneDrive\Documents\Skole\DTU\HDC 2021 - Image ' ...
    'deblurring project course\HDC 2021 Data\HDC2021_step' step '\step' step '\' font '\'];
if strcmp(font,'verdana')
    bfile = ['CAM02\focusStep_' step '_' font 'Ref_size_30_sample_0' sample '.tif']; % blurred 
    xfile = ['CAM01\focusStep_' step '_' font 'Ref_size_30_sample_0' sample '.tif']; % exact
elseif strcmp(font,'times')
    bfile = ['CAM02\focusStep_' step '_' font 'R_size_30_sample_0' sample '.tif']; % blurred 
    xfile = ['CAM01\focusStep_' step '_' font 'R_size_30_sample_0' sample '.tif']; % exact
end
psffile = ['CAM02\focusStep_' step '_PSF.tif']; % psf
b = im2double(imread([folder bfile]));
x = im2double(imread([folder xfile]));
psf = im2double(imread([folder psffile]));
T = 0.8;
psf_thresh = imbinarize(psf,T);

% estimate PSF center and radius
mid = floor(size(psf)/2);
ymid = mid(1); xmid = mid(2);
ll = 100;
psf_cutout = psf_thresh(mid(1)-ll:mid(1)+ll, mid(2)-ll:mid(2)+ll);
PP = psf_cutout<1;
Psum = sum(PP);
r_est = max(Psum(sum(PP)>0)/2);  % estimated radius of HDC data PSF

mu_r = 10;
delta_r = 0.05;
Sr = 100;
sigma_e = 0.015;
lambda_tv = 1;
use_chol = 1;
alpha = 0.5;
K = 5;

figure;
% subplot(131)
% imagesc(x); colormap gray; axis off; 
% title('True Image','FontSize',18,'interpret','latex')
% 
% subplot(132)
% imagesc(b); colormap gray; axis off; 
% title('Blurred and Noisy Image','FontSize',18,'interpret','latex')

subplot(121)
imagesc(psf); colormap gray; axis off; 
xlim([xmid-ll, xmid+ll]);
ylim([ymid-ll, ymid+ll]);
title('Point Spread Function','FontSize',18,'interpret','latex')

subplot(122)
imagesc(psf_cutout); colormap gray; axis off; 
title('Thresholded Point Spread Function','FontSize',18,'interpret','latex')
axis equal

%% Load small test data
clear, clc, close all;
addpath('egrssMatlab')

% -----------   TRUE IMAGE   -----------
x = im2double(imread('data/test.jpg'));

% -----------   PARAMETERS   -----------
true_radius = 10;
true_noise_std = 0.015;

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
%% -----------   TEST deblurring_TV.m   -----------
mu_r = 15;
delta_r = 0.05;
Sr = 100;
sigma_e = std2(b(1:20,1:20)); % estimate noise std from small corner patch
lambda_tv = 1;
use_chol = 1;
alpha = 0.5;
K = 5;
plots = 0;

%close all
for g = 1:length(lambda_tv)
%    close all

    tic
    [X, mu_r_new] = deblurring_TV(b,mu_r,delta_r,lambda_tv(g),sigma_e,K,Sr,alpha,use_chol,plots);
    toc

    %
    fprintf('Initial radius:\n')
    fprintf('mean: %d\n',mu_r)
    fprintf('\nUpdated final radius:\n')
    fprintf('mean: %d\n',mu_r_new)
end
% --------------   PLOTS   --------------
%    close all;

    figure(g);
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
    title(['$\lambda_{TV}$ = ' num2str(lambda_tv(g))],'FontSize',14,'interpret','latex')
%end
