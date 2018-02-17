function dist = nccDist2(I,P1,P2)

N1    = size(P1,1);
N2    = size(P2,1);
dist = 2*ones(N1,N2);
if N1 == N2
    for i = 1 : N1
        for j = i : N2
            dist(i,j) = ncc(I(P1(j,2):P1(j,2)+P1(j,4)-1,P1(j,1):P1(j,1)+P1(j,3)-1),...
                            I(P2(i,2):P2(i,2)+P2(i,4)-1,P2(i,1):P2(i,1)+P2(i,3)-1));
            dist(j,i) = dist(i,j);
        end
    end
else
    for i = 1 : N1
        for j = 1 : N2
            dist(i,j) = ncc(I(P1(i,2):P1(i,2)+P1(i,4)-1,P1(i,1):P1(i,1)+P1(i,3)-1),...
                            I(P2(j,2):P2(j,2)+P2(j,4)-1,P2(j,1):P2(j,1)+P2(j,3)-1));
        end
    end
end
