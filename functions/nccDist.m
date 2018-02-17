function [h,c] = nccDist(I,P,nBins)

N    = size(P,1);
dist = 2*ones(N,N);
for i = 1 : N
    for j = i : N
        dist(i,j) = ncc(I(P(j,2):P(j,2)+P(j,4)-1,P(j,1):P(j,1)+P(j,3)-1),...
                        I(P(i,2):P(i,2)+P(i,4)-1,P(i,1):P(i,1)+P(i,3)-1));        
    end
end

[h,c] = hist(dist(dist~=2),nBins);