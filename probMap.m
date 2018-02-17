function M = probMap(H,W,patches,prob)

M = zeros(H,W);

for i = 1 : size(patches,1)

	M(patches(i,2):patches(i,2)+patches(i,4)-1,patches(i,1):patches(i,1)+patches(i,3)-1) = prob(i);

    
    
end
% function M = probMap(H,W,patches,prob,labels)
% 
% M = zeros(H,W);
% 
% for i = 1 : size(patches,1)
%     
%     if labels(i) == 1
%         M(patches(i,2):patches(i,2)+patches(i,4)-1,patches(i,1):patches(i,1)+patches(i,3)-1) = prob(i,2);
%     end
%     
%     
% end