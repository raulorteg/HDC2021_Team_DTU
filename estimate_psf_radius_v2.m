%% load competition data
clear, clc, close all;
addpath('egrssMatlab')
addpath('PSF')

steps = 0:19;

% load exact PSF
step = '0';
psffile = ['focusStep_' step '_PSF.tif']; % psf
psf_0 = im2double(imread(psffile));

% cut out the center region
mid = floor(size(psf_0)/2);
width = 200;
Cpsf_0 = psf_0(mid(1)-width:mid(1)+width, mid(2)-width:mid(2)+width);
re = 0.2;
Cpsf_0 = imresize(Cpsf_0,re);
% using the noise-free PSF gives radius estimates close to each other, so i
% think we need to use the noisy one
%Cpsf_0 = imcomplement(Cpsf_0);    % noise-free is inverted apparently,
figure(1);
imagesc(Cpsf_0); colormap gray; axis image; 
title(['PSF step: ' num2str(0)],'FontSize',18,'interpret','latex')
drawnow

% parameters
K = 10;
mu_r = 10;
delta_r = 0.3;
alpha = 0.5;
Sr = 200;

mu_r_hist = zeros(length(steps),K+1); mu_r_hist(:,1) = mu_r*ones(length(steps),1);
delta_r_hist = zeros(length(steps),K+1); delta_r_hist(:,1) = delta_r*ones(length(steps),1);

for i = 2:length(steps)
    step = num2str(steps(i));
    psffile = ['focusStep_' step '_PSF.tif']; % psf
    psf = im2double(imread(psffile));
    
    sigma_e = std2(psf(1:20,1:20)); % estimate noise std from small corner patch

    Cpsf = psf(mid(1)-width:mid(1)+width, mid(2)-width:mid(2)+width);
    Cpsf = imresize(Cpsf,re);
    
    % initial guess
    mu_r = 5;
    delta_r = 0.3;

    disp(['step: ' num2str(i-1) ', it: ', num2str(0)])
    disp(['  mu_r: ', num2str(mu_r)])
    disp(['  delta_r: ', num2str(delta_r)])
    
    % estimate radius
    for k = 1:K
        % Update r
        [mu_r, delta_r] = r_update(Cpsf_0, Cpsf, mu_r, delta_r, sigma_e, Sr, alpha);

        disp(['step: ' num2str(i-1) ', it: ', num2str(k)])
        disp(['  mu_r: ', num2str(mu_r)])
        disp(['  delta_r: ', num2str(delta_r)])

        mu_r_hist(i,k+1) = mu_r;
        delta_r_hist(i,k+1) = delta_r;
    end
    
    figure(i);
    imagesc(Cpsf); colormap gray; axis image; 
    title(['PSF step: ' num2str(i-1)],'FontSize',18,'interpret','latex')
    drawnow
end

% PSF radius estimate is final iteration for each step
psf_r_est = mu_r_hist(:,end);