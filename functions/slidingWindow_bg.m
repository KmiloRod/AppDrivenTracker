function wP = slidingWindow_bg(x0,y0,xf,yf,objW,objH,overlap)

% slidingWindow generates a set of patches, or bounding boxes, that are
% used for the FBT tracker to find the target object all over a selected
% squared region denoted by x0,y0 (coordinates of the upper left corner)
% and xf,yf (coordinates of the lower right corner). Each patch overlaps
% with each other by a fraction of overlap. Patches' width and height are 
% objW and objH, respectively.
%
% Output:
% wP is a N-by-4 matrix where each row is a bounding box with four
% components x and y are the upper left coordinates of the bounding box, 
% and W and H are the width and height of the bounding box. 

wStep = round(objW*(1-overlap));
hStep = round(objH*(1-overlap));
% upper left coordinates of the bounding boxes
xl = x0:wStep:xf;
yl = y0:hStep:yf;
% upper right coordinates of the bounding boxes
xr = xf:-wStep:x0;
yr = yf:-hStep:y0;

wP  = zeros(length(xl)*length(yl)+length(xr)*length(yr),4);
ind = 1;
for i = 1 : length(xl)
    for j = 1 : length(yl)
        if (yl(j)+objH)>(yf-y0)
            continue;
        end
        wP(ind,  :) = [xl(i),yl(j),objW,objH];
        if sum(bboxOverlapRatio(wP(ind,:),wP(1:ind-1,:))>overlap)>0
            wP(ind,:) = [];
            ind = ind - 1;
        end
        wP(ind+1,:) = [xr(i)-(objW-1),yr(j)-(objH-1),objW,objH];
        if sum(bboxOverlapRatio(wP(ind+1,:),wP(1:ind,:))>overlap)>0
            wP(ind+1,:) = [];
            ind = ind - 1;
        end
        ind = ind + 2;
    end
end

wP(wP(:,1) < x0 | wP(:,2) < x0 | (wP(:,1) + (objW-1)) > xf | (wP(:,2) + (objH-1)) > yf,:) = [];

