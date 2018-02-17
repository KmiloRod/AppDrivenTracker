function D = searchWindow(objbbox)

step = 2;
dy  = round(-objbbox(4)/2):step:round(objbbox(4)/2); % y
dx  = round(-objbbox(3)/2):step:round(objbbox(3)/2); % x
N   = length(dy)*length(dx);
D   = zeros(N,4);
o   = 1;
for i = dy
    for j = dx
        D(o,1) = j;
        D(o,2) = i;
        o = o + 1;
    end
end