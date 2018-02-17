function dist = nccDist3(P1,P2)

N1    = size(P1,1);
N2    = size(P2,1);
dist = 2*ones(N1,N2);
if N1 == N2
    for i = 1 : N1
        for j = i : N2
            dist(i,j) = ncc(P1(i,:),P2(j,:));
            dist(j,i) = dist(i,j);
        end
    end
else
    for i = 1 : N1
        for j = 1 : N2
            dist(i,j) = ncc(P1(i,:),P2(j,:));
        end
    end
end
