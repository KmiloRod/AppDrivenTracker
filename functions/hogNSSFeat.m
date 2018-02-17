function [featMat] = hogNSSFeat(I,P,NSS,Cs)

% hogFeat receives an gray-scale image I, a N-by-4 matrix of
% patches P where N is the number of patches; a patch (or row) of P is a
% bounding box represented by a vector of four components [x,y,W,H] where x
% and y are the upper left coordinates of the bounding box, and W and H are
% the width and height of the bounding box. NSS is a logical parameter,
% where a value of 1 indicates to add the NSS features to the final feature
% vector. Cs is the scaling parameter that is used to calculate the final
% vector.
%
% hogFeat returns the N-by-Nfeat matrix consisting of the HOG and NSS
% representation of each patch in P.

% HOG descriptor parameters defined as global variables
global BlockSize BlockOverlap CellSize Numbins 
% BlockOverlap must be less than the BlockSize

I = uint8(I); 
P = int32(P);
NSS = logical(NSS);
Cs = single(Cs);

% HOG features paramters
nPatch = size(P,1);
patchSize = [P(1,3) P(1,4)];

% Parse input parameters
hogParams = parseInputs(patchSize, 'CellSize',CellSize,...
                        'BlockSize',BlockSize,'BlockOverlap',BlockOverlap);

[featMat, featLength] = hogNSSFeatOCV(I, P, NSS, Cs, hogParams);
featMat = double(reshape(featMat, [featLength nPatch])');

end
% -------------------------------------------------------------------------
% Input parameter parsing and validation
% -------------------------------------------------------------------------
function params = parseInputs(sz, varargin)
p = getInputParser();
parse(p, varargin{:});
userInput = p.Results;
params = setParams(userInput,sz);
end
%--------------------------------------------------------------------------
function parser = getInputParser()
% p value will be retained in memory between calls to the function
persistent p
if isempty(p)
    
    defaults = getParamDefaults();
    p = inputParser();
    
    addParameter(p, 'CellSize',     defaults.CellSize);
    addParameter(p, 'BlockSize',    defaults.BlockSize);
    addParameter(p, 'BlockOverlap', defaults.BlockOverlap);
    % We don't add WinSize because it depends on CellSize and PatchSize
end
parser = p;
end
% -------------------------------------------------------------------------
% Default parameter values
% -------------------------------------------------------------------------
function defaults = getParamDefaults()
intClass = 'int32';
defaults = struct('CellSize'    , cast([8 8],intClass),...
                  'BlockSize'   , cast([2 2],intClass), ...
                  'BlockOverlap', cast([1 1],intClass), ...
                  'WindowSize', cast([1 1],intClass));
end
% -------------------------------------------------------------------------
% Set input parameters: set an object with the parameters after parsing the
% user input. The c++ function (hogNSSFeatOCV) handles and works with the
% params object.
function params = setParams(userInput, sz)
cell_Size = int32(userInput.CellSize);
% convert window size to legal size for opencv
win_Size = floor([sz(1)./cell_Size(1) sz(2)./cell_Size(2)]);
win_Size = win_Size.*cell_Size;
params.CellSize     = cell_Size;
params.BlockSize    = int32(userInput.BlockSize);
params.BlockOverlap = int32(userInput.BlockOverlap);
params.ImageSize  = int32(sz(1:2));
params.WindowSize = int32(win_Size);
end
