function [friquee_features] = friqueeSubVideoTest(rgb, numOfFrames, featType)

% This function extract the FRIQUEE freatures from subtracted frames of the
% YUV video in FILENAME.
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

% rgb = yuv2rgb_seq(filename, frameSize, numOfFrames);

wait_h = waitbar(0,sprintf('Extracting FRIQUEE features...'));

tic
% numOfFeatures = 72;   % Number of FRIQUEE luma features
% luma_features = zeros(numOfFrames-1, numOfFeatures);
friquee_features = [];

for i = 2:numOfFrames
   waitbar(i/numOfFrames,wait_h);

   % Subtract previous frame from current one
%     curr_frame = rgb(:,:,:,i);
%     prev_frame = rgb(:,:,:,i-1);
      curr_frame = double(rgb2gray(uint8(rgb(:,:,:,i))));
      prev_frame = double(rgb2gray(uint8(rgb(:,:,:,i-1))));

    sub_frame = curr_frame - prev_frame;
   
%     % Convert the input RGB image to LAB color space.
%     lab=convertRGBToLAB(sub_frame);
%     % Get the A and B components of the LAB color space.
%     A = double(lab(:,:,2));
%     B = double(lab(:,:,3));
%     % Compute the chroma map.
%     chroma = sqrt(A.*A + B.*B);

    % Convert the input RGB image to LMS color space.
%     lms = convertRGBToLMS(sub_frame);
%     coefficients = lmsColorOpponentFeats(lms); % Color opponency features.

   %frame_features = extractFRIQUEEFeatures_noCDiv(sub_frame);
   %friquee_features = [friquee_features; frame_features.friqueeALL];
    switch featType
        case 'mscn'
            [coefficients, ~] = divisiveNormalization(sub_frame);
        case 'sigma'
            [coefficients, ~] = divisiveNormalization(chroma);
        case 'npp'
            [coefficients, ~] = divisiveNormalization(chroma);
        case 'DoG'
            [coefficients] = DoGFeat(chroma);
        case 'Lap'
            [coefficients] = lapPyramidFeats(chroma);
        case 'yellow'
            coefficients = yellowColorChannelMap(sub_frame);
        case 'colorOpp'
            lms = convertRGBToLMS(sub_frame);
            coefficients = lmsColorOpponentFeats(lms); % Color opponency features.
    end

%    [coefficients, ~] = divisiveNormalization(sub_frame);
   
%     [coefficients, ~] = divisiveNormalization(computeSigmaMap(sub_frame));
%     coefficients = neighboringPairProductFeats(sub_frame); 
%      [coefficients] = DoGFeat(sub_frame);
%     [coefficients] = lapPyramidFeats(sub_frame);
    %coefficients = yellowColorChannelMap(sub_frame);
   
   coefficients = coefficients(:);
   friquee_features = [friquee_features; coefficients];
end
toc
close(wait_h);
warning(w);