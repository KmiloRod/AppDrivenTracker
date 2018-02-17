function [featMat] = hogFeat(I,patches)

global BlockSize BlockOverlap CellSize Numbins

nPatch = size(patches,1);
xmin = patches(1,1); xmax = xmin + patches(1,3)-1;
ymin = patches(1,2); ymax = ymin + patches(1,4)-1;

% BlockOverlap must be less than the BlockSize


featFst = extractHOGFeatures(I(ymin:ymax,xmin:xmax,:),'CellSize',CellSize,'BlockSize',BlockSize,'BlockOverlap',BlockOverlap);
featMat = zeros(nPatch,length(featFst));
featMat(1,:) = featFst;
for i = 2 : nPatch
    xmin = patches(i,1); xmax = xmin + patches(i,3)-1;
    ymin = patches(i,2); ymax = ymin + patches(i,4)-1;
    featMat(i,:)  = extractHOGFeatures(I(ymin:ymax,xmin:xmax,:),'CellSize',CellSize,'BlockSize',BlockSize,'BlockOverlap',BlockOverlap);

end

