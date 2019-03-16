clear;

DirInfo = dir;
n = size(DirInfo,1);

coeff_prst = [];
blocksizecol = 96; blocksizerow = 96; blockrowoverlap = 8; blockcoloverlap = 8;
filtlength1 = 7; filtlength2 = 7;
filtlength = [filtlength1 filtlength2];
width = 1920; height = 1080;
numFrames = 150;

for i=3:n
    name = DirInfo(i).name;
    if strcmp(name(end-3:end),'.yuv')
        coeff_prst = [coeff_prst; computePatchFRIQUEEcoeff(name,height,width,numFrames,blocksizerow,blocksizecol,blockrowoverlap,blockcoloverlap)];
    end
end