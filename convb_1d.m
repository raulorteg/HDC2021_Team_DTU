function c=convb_1d(g,r)
%This function conv g and out of focus blurring kernel with reflection boundary.
%function c=convb_outfocus(g,r);
%r is the radius of the point spread function.

g = g(:);
PSF = fspecial('disk', r);
p = (size(PSF, 1) - 1) / 2;
PSF = PSF(p+1,:);
g2 = padarray(g, [p,0], 'symmetric');
c = conv(g2, PSF, 'valid');