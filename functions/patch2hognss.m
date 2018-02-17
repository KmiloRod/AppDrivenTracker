function [set] = patch2hognss(I,objP,bgP,nss)

if size(I,4) == 3
    I = rgb2gray(uint8(I));    
end
I = double(I);

Nobj = size(objP,1);
Nbg  = size(bgP ,1);
P    = [objP;bgP];
if nss == 1
    nssSet    = nssFeat(I,P);
    hogSet    = hogFeat(I,P);
    hognssSet = [hogSet,nssSet];    
     
    set.obj.hognssSet = hognssSet(1:Nobj,:);
    set.obj.Nobj      = Nobj;
    set.bg.hognssSet  = hognssSet(Nobj+1:Nobj+Nbg,:);
    set.bg.Nbg        = Nbg;
else
    hogSet = hogFeat(I,P);     
    set.obj.hogSet = hogSet(1:Nobj,:);
    set.obj.Nobj      = Nobj;
    set.bg.hogSet  = hogSet(Nobj+1:Nobj+Nbg,:);
    set.bg.Nbg        = Nbg;
end
 
