function [X, mu_r] = deblurring_TV(B,mu_r,delta_r,lambda,sigma,K,Sr,alpha,usechol,plots)
% syntax: function [x, mu_r] = deblurring_TV_r_est(B,mu_r,delta_r,sigma,K,Sr,alpha)
%
% Inputs:
%           b = blurred image
%           mu_r = initial PSF radius mean estimate
%           delta_r = initial PSF radius standard deviation estimate
%           lambda = regularization parameter for Total Variation (TV) term
%           sigma = noise level
%           K = number of outer iterations (default 10)
%           Sr = Number of radius samples drawn from normal distribution (default 500)
%           alpha = Relaxation parameter for variance term (default 0.5)
%           usechol = Boolean variable for chol usage (1 if yes 0 if no)
%
% Outputs:
%           X = deblurred image
%           mu_r = estimated mean radius of PSF
%-----------------------------------------------------------------

if nargin < 5
    K = 10;
    Sr = 500;
    alpha = 0.5;
elseif nargin < 6
    Sr = 500;
    alpha = 0.5;
elseif nargin < 7
    alpha = 0.5;
end

X = B; % Initial guess 

disp(['it: ', num2str(0)])
disp(['  mu_r: ', num2str(mu_r)])
disp(['  delta_r: ', num2str(delta_r)])

% Main loop
for k = 1:K
    % Update estimation of mean PSF radius mu_r
    [mu_r, delta_r] = r_update_blockwise(X,B,mu_r,delta_r,sigma,Sr,alpha);
    
    % Update estimation of deblurred image x
    X = x_update(X,mu_r,delta_r,B,sigma,Sr,lambda,usechol);

    if plots == 1
        figure;
        subplot(1,3,1)
        imagesc(X); colormap gray; axis off; 
        h = colorbar; 
        h.Limits = [0 1];
        title('Before filters','FontSize',14,'interpret','latex')
    end
    
    % Run through filter to remove blurring from regularization
    %X = adpmedian(X);
    X = medfilt2(X);
    
    if plots == 1
        subplot(1,3,2)
        imagesc(X); colormap gray; axis off; 
        h = colorbar; 
        h.Limits = [0 1];
        title('After first filter','FontSize',14,'interpret','latex')
    end
    % Do edge enhancement     
    X = imbilatfilt(X,2*sigma,4);

    if plots == 1
        subplot(1,3,3)
        imagesc(X); colormap gray; axis off; 
        h = colorbar; 
        h.Limits = [0 1];
        title('After second filter','FontSize',14,'interpret','latex')
    end
    
    disp(['it: ', num2str(k)])
    disp(['  mu_r: ', num2str(mu_r)])
    disp(['  delta_r: ', num2str(delta_r)])
end
