function [mu_r, delta_r] = r_update_blockwise_old(X,B,mu_r,delta_r,sigma,Sr,alpha)
% syntax: [mu_r, delta_r] = r_update_blockwise(X,B,mu_r,delta_r,sigma)
%
% INPUT
% X:        Initial guess of exact image
% B:        Blurred and noisy image
% mu_r:     Mean radius of PSF
% delta_r:  Variance of PSF
% sigma:    The standard deviation of the noise 
% Sr:       Number of model error samples

% Cut image into 100x100 blocks which we can manage
[m,n] = size(X);
sz = 3*ceil(mu_r);  % makes block size dependent on PSF radius estimate
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
        x_blocks(:,:,count) = X(rows,cols); % saves blocks as layers in 3d array
        b_blocks(:,:,count) = B(rows,cols);
    end
end

% x = X(:);
% b = B(:);

mu_r_new = zeros(count,1);
delta_r_new = zeros(count,1);

for k = 1:count
    XX = x_blocks(:,:,k);
    Bblock = b_blocks(:,:,k);
    b = Bblock(:);
    [m,n] = size(XX); % 100x100
    
    eta = zeros(m*n,Sr);
    
    % Precompute forward operation once for efficiency
    A_mu_r_x = A_fun(mu_r,XX);
    
    % Sample radius
    r = max(normrnd(mu_r,delta_r,Sr,1),1); % r needs to be at least 1 pixel
    for i = 1:Sr
        eta(:,i) = A_fun(r(i),XX) - A_mu_r_x;
    end

    % Compute (23), (24), and (25)
    mu_tilde = mean(eta,2); % Sample mean
    mean_r = mean(r);
    c_tilde = (eta-mu_tilde)*(r-mean_r)/(Sr-1); % Cross-covariance
    C_tilde = cov(eta'); %cov((eta-mu_tilde)'); % Sample covariance - invariant to subtraction

%    C_tilde = zeros(n*m,n*m); %c_tilde = zeros(m*n,1);
%     for i = 1:Sr
%         em = eta(:,i) - mu_tilde;
%         C_tilde = C_tilde + 1/(Sr - 1)*(em*em'); % Sample covariance
%         %c_tilde = c_tilde + 1/(Sr - 1)*em*(r(i) - mean_r)'; % Cross-covariance
%     end

    % Update mu_r and delta_r
    nC = size(C_tilde,1);
    invCsig = (C_tilde + sigma^2*eye(nC))\eye(nC);
    ctilxCinv = c_tilde'*invCsig;
    mu_r_new(k) = mu_r + ctilxCinv*(b - A_mu_r_x - mu_tilde);
    delta_r_new(k) = delta_r - alpha*ctilxCinv*c_tilde;
end

mu_r = mean(mu_r_new);
delta_r = mean(delta_r_new);

end

function Ax = A_fun(r,X)
Ax = convb(X,r);
Ax = Ax(:);
end
