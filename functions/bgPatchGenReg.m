function [bgP,final_overlap] = bgPatchGenReg(objbbox,context,Nbg,imSize,overlap)
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

% Regularly distributed bg bboxes 
% overlap = 0.1;
% Nbg_tmp = 0;
Nbg_tmp = Nbg + 1;
while Nbg_tmp > Nbg
    bgP  = slidingWindow_bg(1,1,W,H,xSize,ySize,overlap);
%     bgP  = outsideContext(bgP,context,xSize,ySize,imSize);
    bgP(bboxOverlapRatio(bgP,context)>0,:)=[];
    overlap = overlap - 0.05;
    Nbg_tmp = size(bgP,1);
end
final_overlap = overlap + 0.05;
% keys        = abs(bgP(:,1)).*(10.^(ceil(log10(abs(bgP(:,2)))))) + abs(bgP(:,2));
% key_objbbox = abs(objbbox(:,1)).*(10.^(ceil(log10(abs(objbbox(:,2)))))) + abs(objbbox(:,2));
% if Nbg_tmp > Nbg
%     Ndel = Nbg_tmp - Nbg;
% 	[~,Isort] = sort(abs(keys-key_objbbox),'ascend');
%     bgP = bgP(Isort,:);
%     bgP = bgP(1:end-(Ndel-1),:);
%     
% end


% if ~isempty(context)
%     bgP   = [bgP;patchGen([1 context(1)],[1 context(2)],H,W,[H context(4)],[W context(3)],Nbg,xSize,ySize)];
%     while size(bgP,1) < Nbg
%         bgP   = [bgP; patchGen([1 context(1)],[1 context(2)],H,W,[H context(4)],[W context(3)],Nbg,xSize,ySize)];
%     end
%     bgP   = bgP(1:Nbg,:);
% else
% %     disp(':)')
%     N = round(Nbg/4);
%     x1 = objbbox(1)-objbbox(3);
%     x2 = objbbox(1)+(objbbox(3)-1);
%     y1 = objbbox(2)-objbbox(4);
%     y2 = objbbox(2)+(objbbox(4)-1);
%     
%     
%     X = linspace(x1,x2,N);
%     Y = y1*ones(1,N);
%     X = [X,x2*ones(1,N)];
%     Y = [Y,linspace(y1,y2,N)];
% 	X = [X,x1*ones(1,N)];
%     Y = [Y,linspace(y1,y2,N)];
% 	X = [X,linspace(x1,x2,N)];
%     Y = [Y,y2*ones(1,N)];
%     
%     X = round(X);
%     Y = round(Y);
%     
% 	bgP = zeros(length(X),4);
%     bgP(:,1) = X;
%     bgP(:,2) = Y;
%     bgP(:,3) = xSize; 
%     bgP(:,4) = ySize;
%     bgP( X + (xSize-1) > W | X < 1 | Y + (ySize-1) > H | Y < 1, :) = [];
%     
%     
% end


