function c=convb(g,r)
%This function conv g and out of focus blurring kernel with reflection boundary.
%function c=convb_outfocus(g,r);
%r is the radius of the point spread function.

if isvector(g)
    g = g(:);
    PSF = fspecial('disk', r);
    p = (size(PSF, 1) - 1) / 2;
    PSF = PSF(p+1,:);
    PSF = PSF/sum(PSF);
    g2 = padarray(g, [p,0], 'symmetric');
    c = conv(g2, PSF, 'valid');
else
    PSF = fspecial('disk', r);
    p = (size(PSF, 1) - 1) / 2;
    g = padarray(g,[p p], 'symmetric');
    c = conv2(g, PSF, 'valid');
end

