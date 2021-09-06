function [mu_r, delta_r] = r_update(X,B,mu_r,delta_r,sigma,Sr)
% syntax: [mu_r, delta_r] = r_update_blockwise(X,B,mu_r,delta_r,sigma)
%
% INPUT
% X:        Initial guess of exact image
% B:        Blurred and noisy image
% mu_r:     Mean radius of PSF
% delta_r:  Variance of PSF
% sigma:    The standard deviation of the noise 
% Sr:       Number of model error samples

% x = X(:);
% b = B(:);

x = X(:);
b = B(:);

[m,n] = size(X);
N = m*n;

% Parameters
alpha = 0.1; % best value in report, can be tuned

% Sample model error
A_mu_r_x = A_fun(mu_r,X);
eta = zeros(N,Sr);
r = zeros(Sr,1);

for i = 1:Sr
    r(i) = normrnd(mu_r,delta_r); % r needs to be positive
    while r(i)<0
        r(i) = normrnd(mu_r,delta_r);
    end
    eta(:,i) = A_fun(r(i),X) - A_mu_r_x;
end

mu_eta = mean(eta,2);
mean_r = mean(r);

%c_tilde = zeros(N,1);
%for i = 1:Sr
%    c_tilde = c_tilde + 1/(Sr - 1)*(eta(:,i) - mu_eta)*(r(i) - mean_r)'; % Cross-covariance
%end

c_tilde = (eta - mu_eta)*(r - mean_r)/(Sr-1);

%Compute updates
U = (eta - mu_eta)/sqrt(Sr-1);
Ut = U';

[Wt,c] = egrss_potrf(Ut,Ut,sigma^2);
b_tilde = b - A_fun(mu_r,X) - mu_eta;

sol_tmp = egrss_trsv(Ut,Wt,c,b_tilde);
sol_tmp = egrss_trsv(Ut,Wt,c,sol_tmp,'T');
mu_r = mu_r + c_tilde'*sol_tmp;

sol_tmp = egrss_trsv(Ut,Wt,c,c_tilde);
sol_tmp = egrss_trsv(Ut,Wt,c,sol_tmp,'T');

delta_r = sqrt(delta_r^2 - alpha*c_tilde'*sol_tmp);
end

function Ax = A_fun(r,X)
Ax = convb(X,r);
Ax = Ax(:);
end