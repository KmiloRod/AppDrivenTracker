function [bgP,objP,objbbox] = posAndNegPatchesV2(objbbox,H,W,p)


[objP,objbbox]  = moveObjBbox(objbbox,p,W,H);
nP    = size(objP,1);
xSize = objP(1,3); 
ySize = objP(1,4);
bgP   = patchGen([1 objbbox(1)],[1 objbbox(2)],H,W,[H objbbox(4)],[W objbbox(3)],nP,xSize,ySize);
while size(bgP,1) < 900
    bgP   = [bgP; patchGen([1 objbbox(1)],[1 objbbox(2)],H,W,[H objbbox(4)],[W objbbox(3)],nP,xSize,ySize)];
end
bgP   = bgP(1:900,:);
% while size(bgP,1) < 450
%     bgP   = [bgP; patchGen([1 objbbox(1)],[1 objbbox(2)],H,W,[H objbbox(4)],[W objbbox(3)],nP,xSize,ySize)];
% end
% bgP   = bgP(1:450,:);

end