function [mu_r, delta_r] = r_update_blockwise(X,B,mu_r,delta_r,sigma)
% syntax: [mu_r, delta_r] = r_update_blockwise(X,B,mu_r,delta_r,sigma)
%
% INPUT
% X:        Initial guess of exact image
% B:        Blurred and noisy image
% mu_r:     Mean radius of PSF
% delta_r:  Variance of PSF
% sigma:    The standard deviation of the noise 

% Cut image into 100x100 blocks which we can manage
[m,n] = size(X);
sz = 50;
mb = floor(m/sz);
nb = floor(n/sz);
x_blocks = zeros(sz,sz,mb*nb);
b_blocks = zeros(sz,sz,mb*nb);
count = 0;
for i = 1:mb
    for j = 1:nb
        count = count+1;
        rows = (i-1)*sz+1:i*sz;
        cols = (j-1)*sz+1:j*sz;
        x_blocks(:,:,count) = X(rows,cols);
        b_blocks(:,:,count) = B(rows,cols);
    end
end

% x = X(:);
% b = B(:);

% Parameters
alpha = 0.5; % best value in report, can be tuned
Sr = 500;

mu_r_new = zeros(count,1);
delta_r_new = zeros(count,1);

for k = 1:count
    XX = x_blocks(:,:,k);
    Bblock = b_blocks(:,:,k);
    b = Bblock(:);
    [m,n] = size(XX); % 100x100
    
    eta = zeros(m*n,Sr);
    r = zeros(Sr,1);

    % Sample radius
    for i = 1:Sr
        r(i) = max(normrnd(mu_r,delta_r),1); % r needs to be positive
        eta(:,i) = A_fun(r(i),XX) - A_fun(mu_r,XX);
    end

    % Compute (23), (24), and (25)
    mu_tilde = mean(eta,2); % Sample mean

    C_tilde = zeros(n*m,n*m); c_tilde = zeros(m*n,1);
    mean_r = mean(r);
    for i = 1:Sr
        em = eta(:,i) - mu_tilde;
        C_tilde = C_tilde + 1/(Sr - 1)*(em*em'); % Sample covariance
        c_tilde = c_tilde + 1/(Sr - 1)*em*(r(i) - mean_r)'; % Cross-covariance
    end
    %keyboard

    % Update mu_r and delta_r
    nC = size(C_tilde,1);
    mu_r_new(k) = mu_r + c_tilde'*(C_tilde + sigma^2*eye(nC))^(-1)*(b - A_fun(mu_r,XX) - mu_tilde);
    delta_r_new(k) = delta_r - alpha*c_tilde'*(C_tilde + sigma^2*eye(nC))^(-1)*c_tilde;
end
mu_r = mean(mu_r_new);
delta_r = mean(delta_r_new);

end

function Ax = A_fun(r,X)
Ax = convb(X,r);
Ax = Ax(:);
end