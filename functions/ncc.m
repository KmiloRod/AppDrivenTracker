function coeff = ncc(lPatch1,lPatch2)
%#codegen
% both lPatch1 and lPatch2 are vectors obtained by reshaping a H-by-W patch
% into a (H*W)-by-1 linear array.

lPatch1 = double(lPatch1(:));
lPatch2 = double(lPatch2(:));
N1 = length(lPatch1);
N2 = length(lPatch2);

if N1 == N2    
    P1 = lPatch1 - mean(lPatch1);
    P2 = lPatch2 - mean(lPatch2);
    P1 = P1/norm(P1);
    P2 = P2/norm(P2);    
    coeff = 0.5*(P1'*P2+1);
else
   coeff = 0;
   disp('size(patch1) must be equal to size(patch2)') 
end












end