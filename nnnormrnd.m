function r = nnnormrnd(mu,sigma,sz)
% Non-Negative normrnd
% produces non-negative normal distribution samples in size [1,sz]
% by appropriately mirroring negatives from normrnd to positive values.
% INPUT
% mu : mean
% sigma : standard deviation
% sz : output is size [1,sz]
% OUTPUT
% r : [1,sz] vector of non-negative norm distribution samples

r = normrnd(mu,sigma,1,sz);

neg_val = r(r<0);
if ~isempty(neg_val)
    cdf0 = normcdf(0,mu,sigma);
    neg_cdf = normcdf(neg_val,mu,sigma)/cdf0;
    pos_cdf = cdf0 + (1-cdf0)*(1-neg_cdf);
    pos_val = norminv(pos_cdf,mu,sigma);
    r(r<0) = pos_val;
end

