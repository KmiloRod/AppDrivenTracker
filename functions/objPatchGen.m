function [objP,context] = objPatchGen(objbbox,N,p,imSize)

% N: number of translations in all directions. N = 1 indicates 8
% translations so objP consists of 9 objects.
% p: 
% objLims = [xmin,ymin,xmax,ymax]
H = imSize(1);
W = imSize(2);

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
% step   = min([w_step,h_step]);

% xmin = objbbox(1);
% ymin = objbbox(2);
% xmax = xmin + (objbbox(3)-1);
% ymax = ymin + (objbbox(4)-1);

objP = objbbox;
for i = 1 : N
    objbbox1 = objbbox; objbbox1(2) = objbbox1(2) - i*h_step; % up mov.
    objbbox2 = objbbox; objbbox2(2) = objbbox2(2) + i*h_step; % down mov. 
    objbbox3 = objbbox; objbbox3(1) = objbbox3(1) + i*w_step; % right mov;
    objbbox4 = objbbox; objbbox4(1) = objbbox4(1) - i*w_step; % left mov;
    
    objbbox5 = objbbox; % upper right mov
    objbbox5(2) = objbbox5(2) - i*h_step; 
    objbbox5(1) = objbbox5(1) + i*w_step; 
    
    objbbox6 = objbbox; % lower right mov
    objbbox6(2) = objbbox6(2) + i*h_step; 
    objbbox6(1) = objbbox6(1) + i*w_step; 
    
    objbbox7 = objbbox; % upper left mov
    objbbox7(2) = objbbox7(2) - i*h_step; 
    objbbox7(1) = objbbox7(1) - i*w_step; 
    
    objbbox8 = objbbox; % lower left mov
    objbbox8(2) = objbbox8(2) + i*h_step; 
    objbbox8(1) = objbbox8(1) - i*w_step; 
    
    objP   = [objP;objbbox1;objbbox2;objbbox3;objbbox4;objbbox5;objbbox6;objbbox7;objbbox8];    
end

X     = objP(:,1);
Y     = objP(:,2);
xSize = objP(:,3);
ySize = objP(:,4);
objP( X < 1 | Y < 1 | X + (xSize-1) > W | Y + (ySize-1) > H, :) = [];

minbbox = min(objP);
maxbbox = max(objP);

context = [minbbox(1),minbbox(2),maxbbox(1)+(minbbox(3)-1)-minbbox(1)+1,maxbbox(2)+(minbbox(4)-1)-minbbox(2)+1];


% xmin,ymin,xmax,ymax