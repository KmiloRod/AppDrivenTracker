function [bgP,keys] = bgPatchGen(objbbox,context,Nbg,imSize)
H = imSize(1);
W = imSize(2);

xSize = objbbox(1,3); 
ySize = objbbox(1,4);

if mod(xSize,2) == 0
   xSize = xSize + 1;
   objbbox(3) = xSize;
end
if mod(ySize,2) == 0
   ySize = ySize + 1;
   objbbox(4) = ySize;
end

if ~isempty(context)
    bgP   = patchGen([1 context(1)],[1 context(2)],H,W,[H context(4)],[W context(3)],Nbg,xSize,ySize);
    while size(bgP,1) < Nbg
        bgP   = [bgP; patchGen([1 context(1)],[1 context(2)],H,W,[H context(4)],[W context(3)],Nbg,xSize,ySize)];
    end
    bgP   = bgP(1:Nbg,:);
else
%     disp(':)')
    N = round(Nbg/4);
    x1 = objbbox(1)-objbbox(3);
    x2 = objbbox(1)+(objbbox(3)-1);
    y1 = objbbox(2)-objbbox(4);
    y2 = objbbox(2)+(objbbox(4)-1);
    
    
    X = linspace(x1,x2,N);
    Y = y1*ones(1,N);
    X = [X,x2*ones(1,N)];
    Y = [Y,linspace(y1,y2,N)];
	X = [X,x1*ones(1,N)];
    Y = [Y,linspace(y1,y2,N)];
	X = [X,linspace(x1,x2,N)];
    Y = [Y,y2*ones(1,N)];
    
    X = round(X);
    Y = round(Y);
    
	bgP = zeros(length(X),4);
    bgP(:,1) = X;
    bgP(:,2) = Y;
    bgP(:,3) = xSize; 
    bgP(:,4) = ySize;
    bgP( X + (xSize-1) > W | X < 1 | Y + (ySize-1) > H | Y < 1, :) = [];
    
    
end

keys = abs(bgP(:,1)).*(10.^(ceil(log10(abs(bgP(:,2)))))) + abs(bgP(:,2));

