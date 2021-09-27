function [mu_r, delta_r] = r_update_1d(x,b,mu_r,delta_r,sigma,Sr)
% syntax: [mu_r, delta_r] = r_update_blockwise(X,B,mu_r,delta_r,sigma)
%
% INPUT
% X:        Initial guess of exact image
% B:        Blurred and noisy image
% mu_r:     Mean radius of PSF
% delta_r:  Variance of PSF
% sigma:    The standard deviation of the noise 
% Sr:       Number of model error samples

x = x(:);
b = b(:);

[m,n] = size(x);
N = m*n;

% Parameters
alpha = 0.1; % best value in report, can be tuned

% Sample model error
A_mu_r_x = A_fun(mu_r,x);
eta = zeros(N,Sr);
r = zeros(Sr,1);

for i = 1:Sr
    r(i) = nnnormrnd(mu_r,delta_r,1); % r needs to be positive
    eta(:,i) = A_fun(r(i),x) - A_mu_r_x;
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

%[Wt,c] = egrss_potrf(Ut,Ut,sigma^2);
b_tilde = b - A_fun(mu_r,x) - mu_eta;

%w = (I*sigma^2+Ut*U)\(b-A*r_est*x-model_error)
sol_tmp = (eye(N)*sigma.^2 + U*Ut)\(b_tilde);
% (sigma^2 + U'U)sol_tmp = b_tilde
%sol_tmp = egrss_trsv(Ut,Wt,c,b_tilde);
%sol_tmp = egrss_trsv(Ut,Wt,c,sol_tmp,'T');


mu_r = mu_r + c_tilde'*sol_tmp;

% solve (sigma^2 ´u'u)sol_temp = c_tilde
sol_tmp = (eye(N)*sigma.^2 + U*Ut)\c_tilde;
%sol_tmp = egrss_trsv(Ut,Wt,c,c_tilde);
%sol_tmp = egrss_trsv(Ut,Wt,c,sol_tmp,'T');

delta_r = sqrt(delta_r^2 - alpha*c_tilde'*sol_tmp);
end

function Ax = A_fun(r,x)
Ax = convb(x,r);
Ax = Ax(:);
end