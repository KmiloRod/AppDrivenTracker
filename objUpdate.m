function [objP,hogFeatSet_nxt,dist1,objFrames] = objUpdate(I,i,method,Nobj_max,objbbox,objP_curr,objFrames,hogFeatSet_curr)

disp(':|')
Nobj = size(objP_curr,1);
Nbg  = size(hogFeatSet_curr,1) - Nobj;
hogObj    = hogFeat(I,objbbox); 
hogSobj_avg = mean(hogFeatSet_curr);
dist1_add = sqrt(sum((hogObj- hogSobj_avg).^2,2));

if Nobj == Nobj_max
    hogFeatSet_curr(Nobj,:) = hogSobj;
    objP(Nobj,:) = objbbox;
    objFrames(Nobj) = i;
%     binCode(Nobj,:) = objCode;
    dist1(Nobj)     = dist1_add;
else
    hogFeatSet_nxt = [hogFeatSet_curr(1:Nobj,:);hogObj;hogFeatSet_curr(Nobj+1:Nobj+Nbg,:)]; 
    objP    = [objP;objbbox];
    objFrames = [objFrames;i];
%     binCode   = [binCode;objCode];                            
    dist1     = [dist1_;dist1_add];       
end