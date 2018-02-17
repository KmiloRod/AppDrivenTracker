function pVar = patchVariance(I,P)

pVar    = zeros(size(P,1),1);
for i = 1 : size(P,1)
    imgP    = selectPatch(I,P(i,:));
    pVar(i) = std(imgP(:));
end