function [objBboxes,objbbox] = moveObjBbox(objbbox,p,W,H)


Wbb = objbbox(3);
Hbb = objbbox(4);

if mod(Wbb,2) == 0
   Wbb = Wbb + 1;
   objbbox(3) = Wbb;
end
if mod(Hbb,2) == 0
   Hbb = Hbb + 1;
   objbbox(4) = Hbb;
end
w_step = round(Wbb*p);
h_step = round(Hbb*p);
step   = min([w_step,h_step]);

xmin = objbbox(1);
ymin = objbbox(2);
xmax = xmin + (objbbox(3)-1);
ymax = ymin + (objbbox(4)-1);

yavg = (ymin + ymax)/2;
xavg = (xmin + xmax)/2;
% yavg = (ymin + ymax)/3;
% xavg = (xmin + xmax)/3;

Ny = length(ymin : step : yavg);
Nx = length(xmin : step : xavg);
N  = min([Ny,Nx]);
N  = 1;
objBboxes = objbbox;
for i = 1 : N
    objbbox1 = objbbox; objbbox1(2) = objbbox1(2) - i*step; % up mov.
    objbbox2 = objbbox; objbbox2(2) = objbbox2(2) + i*step; % down mov. 
    objbbox3 = objbbox; objbbox3(1) = objbbox3(1) + i*step; % right mov;
    objbbox4 = objbbox; objbbox4(1) = objbbox4(1) - i*step; % left mov;
    
    objbbox5 = objbbox; % upper right mov
    objbbox5(2) = objbbox5(2) - i*step; 
    objbbox5(1) = objbbox5(1) + i*step; 
    
    objbbox6 = objbbox; % lower right mov
    objbbox6(2) = objbbox6(2) + i*step; 
    objbbox6(1) = objbbox6(1) + i*step; 
    
    objbbox7 = objbbox; % upper left mov
    objbbox7(2) = objbbox7(2) - i*step; 
    objbbox7(1) = objbbox7(1) - i*step; 
    
    objbbox8 = objbbox; % lower left mov
    objbbox8(2) = objbbox8(2) + i*step; 
    objbbox8(1) = objbbox8(1) - i*step; 
    
    objBboxes   = [objBboxes;objbbox1;objbbox2;objbbox3;objbbox4;objbbox5;objbbox6;objbbox7;objbbox8];    
end

X     = objBboxes(:,1);
Y     = objBboxes(:,2);
xSize = objBboxes(:,3);
ySize = objBboxes(:,4);
objBboxes( X < 1 | Y < 1 | X + (xSize-1) > W | Y + (ySize-1) > H, :) = [];
