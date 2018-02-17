function wBbox = widenBbox(bbox,iper)

xmin_0 = bbox(1); 
W_0    = bbox(3);
xavg_0 = xmin_0 + (W_0-1)*0.5;        
W_1    = W_0*(1+iper);
xavg_1 = xmin_0 + (W_1-1)*0.5;
xmin_1 = xmin_0 - xavg_1;
xmin_1 = xmin_1 + xavg_0;

ymin_0 = bbox(2); 
H_0    = bbox(4);
yavg_0 = ymin_0 + (H_0-1)*0.5;        
H_1    = H_0*(1+iper);
yavg_1 = ymin_0 + (H_1-1)*0.5;
ymin_1 = ymin_0 - yavg_1;
ymin_1 = ymin_1 + yavg_0;

wBbox = round([xmin_1 ymin_1 W_1 H_1]);