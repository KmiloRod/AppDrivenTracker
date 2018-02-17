function [featMat] = hogFeat(I,P)

% hogFeat receives an gray-scale image I and a N-by-4 matrix of
% patches P where N is the number of patches; a patch (or row) of P is a
% bounding box represented by a vector of four components [x,y,W,H] where x
% and y are the upper left coordinates of the bounding box, and W and H are
% the width and height of the bounding box. 
%
% hogFeat returns the N-by-Nhog matrix consisting of the HOG representation
% of each patch in P.

% HOG descriptor parameters defined as global variables
global BlockSize BlockOverlap CellSize Numbins 
% BlockOverlap must be less than the BlockSize

nPatch = size(P,1);
xmin = P(1,1); xmax = xmin + P(1,3)-1;
ymin = P(1,2); ymax = ymin + P(1,4)-1;

% construct hog object
hogObj = HOGDescriptor(size(I(ymin:ymax,xmin:xmax,:)),'CellSize',CellSize,'BlockSize',BlockSize,'BlockOverlap',BlockOverlap);

%featFst = extractHOGFeaturesOCV(I(ymin:ymax,xmin:xmax,:),'CellSize',CellSize,'BlockSize',BlockSize,'BlockOverlap',BlockOverlap);
featFst = compute(hogObj,I(ymin:ymax,xmin:xmax,:));
featMat = zeros(nPatch,length(featFst));
featMat(1,:) = featFst;
for i = 2 : nPatch
    xmin = P(i,1); xmax = xmin + P(i,3)-1;
    ymin = P(i,2); ymax = ymin + P(i,4)-1;
    %featMat(i,:)  = extractHOGFeaturesOCV(I(ymin:ymax,xmin:xmax,:),'CellSize',CellSize,'BlockSize',BlockSize,'BlockOverlap',BlockOverlap);
    featMat(i,:)  = compute(hogObj,I(ymin:ymax,xmin:xmax,:));

end
release(hogObj);