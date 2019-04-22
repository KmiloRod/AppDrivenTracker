function patchFrame = videoPatch(gtP,frames,class)

% Function that calculates a cell array data type, which contains for each
% frame the location of the main patch and the surrounding eight patches
% which are used for the analysis of the extraction of the
% hogs characteristics and in main components analysis.
% gtP is the matrix of [4 x numOfFrames] where the columns of the matrix are
% [x y displacement (x) displacement (y)] and numOfFrames is the amount of
% frames of the video. 
%the variable "class", determines if a data set is to be built with the 
%same sized patches or with the original patches of the gtP, 
%in case of choosing the same size, the size is chosen with the dimensions 
%of the first frame.


    height = size(frames,1);
    width = size(frames,2);
    
%the patches are organized from top to bottom and from left to right 
    switch class
        case 0 %Equal size patches for gtP
            for i = 1:size(gtP,1)
                patchFrame{i}(5,:) = [gtP(i,1)    gtP(i,2)    gtP(1,3)    gtP(1,4)];
                patchFrame{i}(6,:) = [gtP(i,1)    gtP(i,2)-2  gtP(i,3)    gtP(1,4)];
                patchFrame{i}(4,:) = [gtP(i,1)    gtP(i,2)+2  gtP(1,3)    gtP(1,4)];
                patchFrame{i}(2,:) = [gtP(i,1)-2  gtP(i,2)    gtP(1,3)    gtP(1,4)];
                patchFrame{i}(8,:) = [gtP(i,1)+2  gtP(i,2)    gtP(1,3)    gtP(1,4)];
                patchFrame{i}(3,:) = [gtP(i,1)-2  gtP(i,2)-2  gtP(1,3)    gtP(1,4)];
                patchFrame{i}(1,:) = [gtP(i,1)-2  gtP(i,2)+2  gtP(1,3)    gtP(1,4)];
                patchFrame{i}(9,:) = [gtP(i,1)+2  gtP(i,2)-2  gtP(1,3)    gtP(1,4)];
                patchFrame{i}(7,:) = [gtP(i,1)+2  gtP(i,2)+2  gtP(1,3)    gtP(1,4)];
            end 
        otherwise %Original size patches for gtP
           for i = 1:size(gtP,1)
                patchFrame{i}(5,:) = [gtP(i,1)    gtP(i,2)    gtP(i,3)    gtP(i,4)];
                patchFrame{i}(6,:) = [gtP(i,1)    gtP(i,2)-2  gtP(i,3)    gtP(i,4)];
                patchFrame{i}(4,:) = [gtP(i,1)    gtP(i,2)+2  gtP(i,3)    gtP(i,4)];
                patchFrame{i}(2,:) = [gtP(i,1)-2  gtP(i,2)    gtP(i,3)    gtP(i,4)];
                patchFrame{i}(8,:) = [gtP(i,1)+2  gtP(i,2)    gtP(i,3)    gtP(i,4)];
                patchFrame{i}(3,:) = [gtP(i,1)-2  gtP(i,2)-2  gtP(i,3)    gtP(i,4)];
                patchFrame{i}(1,:) = [gtP(i,1)-2  gtP(i,2)+2  gtP(i,3)    gtP(i,4)];
                patchFrame{i}(9,:) = [gtP(i,1)+2  gtP(i,2)-2  gtP(i,3)    gtP(i,4)];
                patchFrame{i}(7,:) = [gtP(i,1)+2  gtP(i,2)+2  gtP(i,3)    gtP(i,4)];
            end  
    end
    
    
    for i = 1:size(gtP,1)
        fila=[];
        for j = 1:size(patchFrame{i},1)
            
            w = patchFrame{i}(j,1)+patchFrame{i}(j,3);
            h = patchFrame{i}(j,2)+patchFrame{i}(j,4);
            x = patchFrame{i}(j,1);
            y = patchFrame{i}(j,2);
            
            if w>width || h>height || x<=0 || y<=0
               fila = cat(1,fila,j); 
            end
            
        end
        
        patchFrame{i}(fila,:)=[];
        
    end 

end