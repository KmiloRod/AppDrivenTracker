function I = drawPatches(I,patches,color)

I = uint8(I);
% if size(I,3) == 1
bboxColor = uint8(255);    
% elseif size(I,3) == 3
%     bboxColor = uint8(ones(1,1,3)*255);
% end

nPatch = size(patches,1);
for i = 1 : nPatch
    xmin = patches(i,1);
    xmax = xmin + (patches(i,3)-1);
	ymin = patches(i,2);
    ymax = ymin + (patches(i,4)-1);
    
% 	I(xmin,ymin:ymax,:) = bboxColor;
%	I(xmax,ymin:ymax,:) = bboxColor;
%	I(xmin:xmax,ymin,:) = bboxColor;
%	I(xmin:xmax,ymax,:) = bboxColor;
    for c = 1 : size(I,3)
        if c == color
            I(ymin,xmin:xmax,c) = bboxColor;
            I(ymax,xmin:xmax,c) = bboxColor;
            I(ymin:ymax,xmin,c) = bboxColor;
            I(ymin:ymax,xmax,c) = bboxColor;
        else
            I(ymin,xmin:xmax,c) = uint8(0);
            I(ymax,xmin:xmax,c) = uint8(0);
            I(ymin:ymax,xmin,c) = uint8(0);
            I(ymin:ymax,xmax,c) = uint8(0);
        end
    end
    
end