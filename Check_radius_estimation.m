clear, clc, close all;
addpath('egrssMatlab')

% -----------   TRUE IMAGE   -----------
x = im2double(imread('data/test.jpg'));

% -----------   PARAMETERS   -----------
true_radius = 12;
init_radius = 26;
true_noise_std = 0.015;
Sr = 100;
sigma_e = 0.015;
usechol = 1;

% -----------   BLUR IMAGE   -----------
psf=fspecial('disk',true_radius);
b0 = convb(x,true_radius);
%bb = b0 + randn(size(b0))*true_noise_std;
b = convb(x,true_radius) + randn(size(x))*true_noise_std; 

figure;
subplot(121)
imagesc(x); colormap gray; axis off; 
title('True Image','FontSize',18,'interpret','latex')

subplot(122)
imagesc(b); colormap gray; axis off; 
title('Blurred and Noisy Image','FontSize',18,'interpret','latex')

lambda = [0.1,1,10];

radius = linspace(1,init_radius,init_radius)'; delta_r = 0.05;

norm_ = zeros(length(radius),length(lambda));

for j = 1:length(lambda)
    X0 = x_update(x,init_radius,delta_r,b,sigma_e,Sr,lambda(j),usechol);
    [mu_r,delta_r] = r_update(X0, b, init_radius, delta_r, sigma_e, Sr);
    for i = 1:length(radius)
        norm_(i,j) = norm(A_fun(radius(i),X0) - b(:),2)^2;
    end
end
%%
close all;
figure;
for j = 1:length(lambda)
    subplot(1,3,j);
    plot(radius,norm_(:,j),'LineWidth',2)
    xlabel('Radius','interpret','latex')
    ylabel('$\|\mathbf{A}(r)*\mathbf{x} - \mathbf{b}\|_2^2$','interpret','latex')
    set(gca,'FontSize',18)
    xlim([min(radius) max(radius)])
    grid on; grid minor;
    title(sprintf('Lambda = %.1f',lambda(j)),'interpret','latex')
end

function Ax = A_fun(r,X)
Ax = convb(X,r);
Ax = Ax(:);
end