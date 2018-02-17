function [objP,context,...
          bgP,bgKeys,binCode,points,bgTsh4,...
          CellSize,BlockSize,BlockOverlap,...
          Numbins,N_HOG] = FBTandMSTInit(objbbox_0,frame_0)

p = 0.05; % step fraction
Nt= 1; % number of traslations
imSize = [size(frame_0,1),size(frame_0,2)]; % [height,width]
[objP,context] = objPatchGen(objbbox_0,Nt,p,imSize);
[objP_bin,context_bin] = objPatchGen(objbbox_0,Nt+1,p,imSize);

objbbox = objP(1,:);

% HOG feature params
objSize = [objbbox(4),objbbox(3)];
CellSize = min(floor(objSize/4))*ones(1,2);
BlockSize = [2 2];
BlockOverlap = ceil(BlockSize/2);
Numbins = 9;
BlocksPerImage = floor(((objSize./CellSize) - BlockSize)./(BlockSize-BlockOverlap) + 1);
N_HOG = prod([BlocksPerImage,BlockSize,Numbins]);
Nbg = floor(N_HOG*0.9);
[bgP,bgKeys] = bgPatchGen(objbbox_0,context,Nbg,imSize);
%[bgP,bgKeys] = bgPatchGenV2(objbbox_0,context,Nbg,imSize);
%[bgP,bgKeys] = bgPatchGenReg(objbbox_0,context,Nbg,imSize,0.7);

% binary descriptor and appearance threshold
if length(size(frame_0)) == 3
    I        = double(rgb2gray(uint8(frame_0(:,:,:,1))));
else
    I        = double(frame_0(:,:,:,1));
end
I_patch  = selectPatch(I,objP(1,:));
S1 = size(I_patch,1);
S2 = size(I_patch,2);
[X,Y] = meshgrid(linspace(1,S1,5),linspace(1,S2,5));
points = floor([X(:),Y(:)]);


binCode = briefDescriptor(I_patch,points);
for i = 2 : size(objP_bin,1)
    I_patch = I(objP_bin(i,2):objP_bin(i,2)+objP_bin(i,4)-1,objP_bin(i,1):objP_bin(i,1)+objP_bin(i,3)-1);
    binCode = [binCode; briefDescriptor(I_patch,points)];
end
D      = pdist(binCode,'hamming');
bgTsh4 = min(D);


% Nobj = size(objP,1);
% Nbg  = size(bgP,1);
% Nobj_max = round(Nbg/1);
% objFrames = ones(Nobj,1);

% simObj = nccDist2(I,objP,objP);
% simObjBg = nccDist2(I,objP,bgP);
% bgTsh  = max(1 - bboxOverlapRatio(objP(1,:),objP));
% bgTsh2 = min(min(simObj));
% bgTsh3 = max(max(simObjBg));
% bgTsh4 = min(D);
