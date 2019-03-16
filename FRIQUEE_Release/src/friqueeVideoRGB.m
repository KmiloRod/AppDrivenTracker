function [friquee_features] = friqueeVideoRGB(rgb, numOfFrames)

% This function extract the FRIQUEE freatures from frames of the video in
% RGB (does not include the yellow map features).
% The extracted FRIQUEE features are:
%   - Neighbouring pair products: 24 (1 - 24)
%   - Sigma map: 3 (25 - 27)
%   - Classical debiased and normalized features: 4 (28 - 31)
%   - Neighbouring pair products (half scaled): 24 (32 - 55)
%   - Sigma map (half scaled): 3 (56 - 58)
%   - Classical debiased and normalized features (half scaled): 4 (59 - 62)
%   - Difference of Gaussian (DoG) of Sigma Map: 6 (63 - 68)
%   - Laplacian of the Luminance Map: 4 (69 - 72)

w = warning('off','all');

%rgb = yuv2rgb_seq(filename, frameSize, numOfFrames);

wait_h = waitbar(0,sprintf('Extracting FRIQUEE features...'));

tic
% numOfFeatures = 72;   % Number of FRIQUEE luma features
% luma_features = zeros(numOfFrames-1, numOfFeatures);
friquee_features = [];

for i = 1:numOfFrames
   waitbar(i/numOfFrames,wait_h);

   %sub_frame = double(rgb2gray(uint8(rgb(:,:,:,i))));
   sub_frame = rgb(:,:,:,i);

   frame_features = extractFRIQUEEFeatures_noCDiv(sub_frame);
   friquee_features(i,:) = frame_features.friqueeALL;
%    luma_features(i,:) = friqueeLuma(sub_frame);   
%    [coefficients, ~] = divisiveNormalization(sub_frame);
%    coefficients = computeSigmaMap(sub_frame);
%    [~, coeff_column] = neighboringPairProductFeats(sub_frame); 
%    [~,coefficients] = DoGFeat(sub_frame);
%    [~, coefficients] = lapPyramidFeats(sub_frame);
   
%    coeff_column = reshape(coefficients, [size(coefficients,1)*size(coefficients,2), 1]);
%    luma_features = [luma_features; coeff_column];
end
toc
close(wait_h);
warning(w);