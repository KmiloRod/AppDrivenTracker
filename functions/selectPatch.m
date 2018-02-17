function I_patch = selectPatch(I,patchBbox)

x_min = patchBbox(1);
x_max = x_min + (patchBbox(3)-1);
y_min = patchBbox(2);
y_max = y_min + (patchBbox(4)-1);

I_patch = I(y_min:y_max,x_min:x_max,:);