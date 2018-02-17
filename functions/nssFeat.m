function [featMat] = nssFeat(I,patches)    

nPatch  = size(patches,1);
window  = fspecial('gaussian',7,7/6); window = window/sum(sum(window));
mu      = imfilter(I,window,'replicate');
mu_sq	= mu.*mu;
sigma	= sqrt(abs(imfilter(I.*I,window,'replicate') - mu_sq));
I_mscn 	= (I-mu)./(sigma+1);

gam   = 0.2:0.001:10;
r_gam = ((gamma(2./gam)).^2)./(gamma(1./gam).*gamma(3./gam));

for i = 1 : nPatch
    xmin = patches(i,1); xmax = xmin + patches(i,3)-1;
    ymin = patches(i,2); ymax = ymin + patches(i,4)-1;
    nssfeat = [computefeature_gam(I_mscn(ymin:ymax,xmin:xmax),gam,r_gam);...
                     computefeature_gam(imresize(I_mscn(ymin:ymax,xmin:xmax),0.5),gam,r_gam)];
    featMat(i,:)  = nssfeat';

end