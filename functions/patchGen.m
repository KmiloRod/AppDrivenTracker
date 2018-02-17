function patches = patchGen(x,y,H,W,Hbb,Wbb,nPatch,xSize,ySize)


dx = x(1) - 1;
dy = y(1) - 1;

if length(x)==2 && length(y)==2 && length(Hbb)==2 && length(Wbb)==2    
    xmin_bg = x(1); xmax_bg = xmin_bg + (Wbb(1)-1);
    ymin_bg = y(1); ymax_bg = ymin_bg + (Hbb(1)-1);   

    xmin_o = x(2); xmax_o = xmin_o + (Wbb(2)-1);
    ymin_o = y(2); ymax_o = ymin_o + (Hbb(2)-1);   

    X = zeros(nPatch(1),1);
    Y = zeros(nPatch(1),1);

    if (xmin_bg < xmin_o && xmax_bg > xmax_o) && (ymin_bg < ymin_o && ymax_bg > ymax_o)
        nPatch_4   = floor(nPatch(1)/4);
        nPatch_lst = nPatch(1) - 3*nPatch_4;
        
        X(1:nPatch_4) = randi((xmin_o-xmin_bg),nPatch_4,1) + dx;
        Y(1:nPatch_4) = randi(Hbb(1),nPatch_4,1) + dy; 

        X(nPatch_4+1:2*nPatch_4)   = (xmax_o-1) + randi((xmax_bg-xmax_o),nPatch_4,1);
        Y(nPatch_4+1:2*nPatch_4)   = randi(Hbb(1),nPatch_4,1) + dy;

        X(2*nPatch_4+1:3*nPatch_4) = randi(Wbb(1),nPatch_4,1) + dx;
        Y(2*nPatch_4+1:3*nPatch_4) = randi((ymin_o-ymin_bg),nPatch_4,1) + dy;

        X(3*nPatch_4+1:nPatch(1))  = randi(Wbb(1),nPatch_lst,1) + dx;
        Y(3*nPatch_4+1:nPatch(1))  = (ymax_o-1) + randi((ymax_bg-ymax_o),nPatch_lst,1);  
 
    elseif (xmin_bg < xmin_o && xmax_bg == xmax_o) && (ymin_bg < ymin_o && ymax_bg > ymax_o)
        nPatch_3   = floor(nPatch(1)/3);
        nPatch_lst = nPatch(1) - 2*nPatch_3;
        
        X(1:nPatch_3) = randi((xmin_o-xmin_bg),nPatch_3,1) + dx;
        Y(1:nPatch_3) = randi(Hbb(1),nPatch_3,1) + dy; 

        X(nPatch_3+1:2*nPatch_3) = randi(Wbb(1),nPatch_3,1) + dx;
        Y(nPatch_3+1:2*nPatch_3) = randi((ymin_o-ymin_bg),nPatch_3,1) + dy;

        X(2*nPatch_3+1:nPatch(1))  = randi(Wbb(1),nPatch_lst,1) + dx;
        Y(2*nPatch_3+1:nPatch(1))  = (ymax_o-1) + randi((ymax_bg-ymax_o),nPatch_lst,1);  
        
    elseif (xmin_bg == xmin_o && xmax_bg > xmax_o) && (ymin_bg < ymin_o && ymax_bg > ymax_o)
        nPatch_3   = floor(nPatch(1)/3);
        nPatch_lst = nPatch(1) - 2*nPatch_3;
        
        X(1:nPatch_3)   = (xmax_o-1) + randi((xmax_bg-xmax_o),nPatch_3,1);
        Y(1:nPatch_3)   = randi(Hbb(1),nPatch_3,1) + dy;

        X(nPatch_3+1:2*nPatch_3) = randi(Wbb(1),nPatch_3,1) + dx;
        Y(nPatch_3+1:2*nPatch_3) = randi((ymin_o-ymin_bg),nPatch_3,1) + dy;

        X(2*nPatch_3+1:nPatch(1))  = randi(Wbb(1),nPatch_lst,1) + dx;
        Y(2*nPatch_3+1:nPatch(1))  = (ymax_o-1) + randi((ymax_bg-ymax_o),nPatch_lst,1); 
        
    elseif (xmin_bg < xmin_o && xmax_bg > xmax_o) && (ymin_bg == ymin_o && ymax_bg > ymax_o)
        nPatch_3   = floor(nPatch(1)/3);
        nPatch_lst = nPatch(1) - 2*nPatch_3;
        
        X(1:nPatch_3) = randi((xmin_o-xmin_bg),nPatch_3,1) + dx;
        Y(1:nPatch_3) = randi(Hbb(1),nPatch_3,1) + dy; 

        X(nPatch_3+1:2*nPatch_3)   = (xmax_o-1) + randi((xmax_bg-xmax_o),nPatch_3,1);
        Y(nPatch_3+1:2*nPatch_3)   = randi(Hbb(1),nPatch_3,1) + dy;

        X(2*nPatch_3+1:nPatch(1))  = randi(Wbb(1),nPatch_lst,1) + dx;
        Y(2*nPatch_3+1:nPatch(1))  = (ymax_o-1) + randi((ymax_bg-ymax_o),nPatch_lst,1);
        
    elseif (xmin_bg < xmin_o && xmax_bg > xmax_o) && (ymin_bg < ymin_o && ymax_bg == ymax_o)
        
        nPatch_3   = floor(nPatch(1)/3);
        nPatch_lst = nPatch(1) - 2*nPatch_3;
        
        X(1:nPatch_3) = randi((xmin_o-xmin_bg),nPatch_3,1) + dx;
        Y(1:nPatch_3) = randi(Hbb(1),nPatch_3,1) + dy; 

        X(nPatch_3+1:2*nPatch_3)   = (xmax_o-1) + randi((xmax_bg-xmax_o),nPatch_3,1);
        Y(nPatch_3+1:2*nPatch_3)   = randi(Hbb(1),nPatch_3,1) + dy;

        X(2*nPatch_3+1:nPatch(1)) = randi(Wbb(1),nPatch_lst,1) + dx;
        Y(2*nPatch_3+1:nPatch(1)) = randi((ymin_o-ymin_bg),nPatch_lst,1) + dy;        
    else
        error('object bounding box must be defined inside the contex window (or background bounding box)')
    end 
    patches(:,1) = X;
    patches(:,2) = Y;
    patches(:,3) = xSize; 
    patches(:,4) = ySize;
    patches( X + (xSize-1) > W | Y + (ySize-1) > H, :) = []; 
    Y = patches(:,2);
    X = patches(:,1);
    xFilter = (X >= xmin_o & X <= xmax_o) | (X < xmin_o & (X + xSize-1) > xmin_o) | (X < xmax_o & (X + xSize-1) > xmax_o);
    patches((Y + (ySize-1) > ymin_o & Y < ymin_o & xFilter) | ...
            (Y >= ymax_o & Y + (ySize-1) > ymax_bg) | ...
            (Y > ymin_o  & Y < ymax_o & xFilter) , :)   = [];

    Y = patches(:,2);
    X = patches(:,1); 
    yFilter = (Y >= ymin_o & Y <= ymax_o) | (Y < ymin_o & (Y + ySize-1) > ymin_o) | (Y < ymax_o & (Y + ySize-1) > ymax_o);
    patches((X + (xSize-1) > xmin_o & X < xmin_o & yFilter) | ...
            (X >= xmax_o & X + (xSize-1) > xmax_bg) | ...
            (X > xmin_o & X < xmax_o & yFilter) , :)   = [];
else

    xmin_o = x(1); xmax_o = xmin_o + (Wbb(1)-1);
    ymin_o = y(1); ymax_o = ymin_o + (Hbb(1)-1);  

    % Patches' upper left corner positions
    Y  = randi(Hbb(1),nPatch,1) + dy;
    X  = randi(Wbb(1),nPatch,1) + dx;

    patches = zeros(nPatch,4);
    patches(:,1) = X;
    patches(:,2) = Y;
    patches(:,3) = xSize; 
    patches(:,4) = ySize;
    patches( X + (xSize-1) > W | Y + (ySize-1) > H, :) = [];
    X = patches(:,1);
    Y = patches(:,2);
    patches( X + (xSize-1) > xmax_o | Y + (ySize-1) > ymax_o, :) = [];

end







end