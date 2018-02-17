function binCode = briefDescriptor(I_patch,points)

% I, smoothed gray scale image
x = points(:,1);
y = points(:,2);

N = size(points,1);
% I_patch = I(patch(1):patch(1)+patch(3),patch(2):patch(2)+patch(4));
binCode = [];
for i = 1 : N
    for j = 1 : N
       if i ~= j
          binCode = [binCode, I_patch(x(j),y(j)) > I_patch(x(i),y(i))]; 
       end
    end   
end