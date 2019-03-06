function inBounds = isBboxInBounds(bbox, imSize)

areaBbox = bbox(3) * bbox(4);
inBounds = rectint(bbox, [0, 0, imSize(2), imSize(1)]) == areaBbox;
if length(find(bbox)) < size(bbox,2)
    inBounds = false;
end
