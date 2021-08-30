function [X, mu_r] = deblurring_TV(B,mu_r,delta_r,lambda,sigma,K,Sr,alpha,usechol)
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

X = B;      % Initial guess is the blurred image

disp(['it: ', num2str(0)])
disp(['  mu_r: ', num2str(mu_r)])
disp(['  delta_r: ', num2str(delta_r)])

% Main loop
for k = 1:K
    % Update estimation of mean PSF radius mu_r
    [mu_r, delta_r] = r_update_blockwise_old(X,B,mu_r,delta_r,sigma,Sr);
    
    % Update estimation of deblurred image x
    X = x_update(X,mu_r,delta_r,B,sigma,Sr,lambda,usechol);

    disp(['it: ', num2str(k)])
    disp(['  mu_r: ', num2str(mu_r)])
    disp(['  delta_r: ', num2str(delta_r)])
end
