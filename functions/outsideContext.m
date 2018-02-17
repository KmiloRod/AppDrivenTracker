function P = outsideContext(P,context,xSize,ySize,imSize)

% outsideContext removes from P all bounding boxes of size ySize-by-xSize
% that does overlap with context which is also a bounding box.
x_min = context(1); 
xmax = x_min + (context(3)-1);
y_min = context(2);
ymax = y_min + (context(4)-1);
Y = P(:,2);
X = P(:,1);
xFilter = (X >= x_min & X <= xmax) | (X < x_min & (X + xSize-1) > x_min) | (X < xmax & (X + xSize-1) > xmax);
P((Y + (ySize-1) > y_min & Y < y_min & xFilter) | ...
        (Y >= ymax & Y + (ySize-1) > imSize(2)) | ...
        (Y > y_min  & Y < ymax & xFilter) , :)   = [];
Y = P(:,2);
X = P(:,1); 
yFilter = (Y >= y_min & Y <= ymax) | (Y < y_min & (Y + ySize-1) > y_min) | (Y < ymax & (Y + ySize-1) > ymax);
P((X + (xSize-1) > x_min& X < x_min& yFilter) | ...
        (X >= xmax & X + (xSize-1) > imSize(1)) | ...
        (X > x_min& X < xmax & yFilter) , :)   = [];



end