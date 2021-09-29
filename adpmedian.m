function [f,F]=adpmedian(g)
%Input:
%g:     Noisy image
%Output:
%f:     Restored image
%F:     logical matrix. Noise detection. F(i,j)=1 means noise; F(i,j)=0 means noise-free.

g=double(g);
[M,N]=size(g);
F=zeros(M,N);
Smax=min(M,N);
gmax=max(g(:));
f=g;
%f(:)=0;
alreadyProcessed=false(size(g));

for k=3:2:Smax
    zmin=ordfilt2(g,1,ones(k,k),'symmetric');
    zmax=ordfilt2(g,k*k,ones(k,k),'symmetric');
    zmed=medfilt2(g,[k,k],'symmetric');
    processUsingLevelB=(zmed>zmin) & (zmax>zmed) &...
        ~alreadyProcessed;
    zB=(g>zmin) & (zmax>g);
    outputZxy=processUsingLevelB & zB;
    outputZmed=processUsingLevelB & ~zB;
   f(outputZxy)=g(outputZxy);
   f(outputZmed)=zmed(outputZmed);
%    F(outputZmed)=1;               
    F(outputZmed)=g(outputZmed)==0 | g(outputZmed)==gmax;        
    alreadyProcessed=alreadyProcessed | processUsingLevelB;
    if all(alreadyProcessed(:))
        break;
    end
end
f(~alreadyProcessed)=zmed(~alreadyProcessed);
F(~alreadyProcessed)=1;
F=~F;