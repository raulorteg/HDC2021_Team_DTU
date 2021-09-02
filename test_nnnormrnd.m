mu = 1;
sigma = 1;
sz = 1000000;
r = nnnormrnd(mu,sigma,sz);
h = histogram(r,100);
h.Normalization = 'probability';
t = linspace(0,max(r),100);
f = max(h.Values) * exp(-0.5*((t-mu).^2)/(sigma^2));

hold on
plot(t,f,'r')
