function wP = slidingWindow2(x0,y0,xf,yf,objW,objH)

wStep = round(objW);
hStep = round(objH);
% upper left coordinates of the bounding boxes
xl = x0:wStep:xf;
yl = y0:hStep:yf;
% upper right coordinates of the bounding boxes
% xr = xf:-wStep:x0;
% yr = yf:-hStep:y0;

wP  = zeros(length(xl)*length(yl),4);
% wP  = zeros(length(xl)*length(yl)+length(xr)*length(yr),4);
ind = 1;
for i = 1 : length(xl)
    for j = 1 : length(yl)        
        wP(ind,  :) = [xl(i),yl(j),objW,objH];   
        ind = ind + 1;
    end
end

wP(wP(:,1) < x0 | wP(:,2) < x0 | (wP(:,1) + (objW-1)) > xf | (wP(:,2) + (objH-1)) > yf,:) = [];

