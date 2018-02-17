%{ 
Author: Deepti Ghadiyaram
Modified by: Camio Rodríguez

Description: Given an input gray image, this method extracts the
FRIQUEE-Luma features proposed in [1] from the Luminance map of an image.

Input: a MXNX3 array of an RGB image 

Output: Features extracted from the luma map (as described in the section
Luminance Feature Maps in [1]  

Dependencies: This method depends on the following methods:
    neighboringPairProductFeats.m
    sigmaMapFeats.m
    debiasedNormalizedFeats.m
    DoGFeat.m
    lapPyramidFeats.m

Reference:
[1] D. Ghadiyaram and A.C. Bovik, "Perceptual Quality Prediction on Authentically Distorted Images Using a
Bag of Features Approach," http://arxiv.org/abs/1609.04757
%}
function feat = friqueeLuma(imGray)
    
    %imGray = double(rgb2gray(rgb));
    %% Initializations
    scalenum=2;
    imGray1=imGray;
    
    % The array that aggregates all the features from different feature
    % maps.
    feat = [];
    
    for itr_scale = 1:scalenum
        % 4 Neighborhood map features of Luma map
       nFeat = neighboringPairProductFeats(imGray);
       feat = [feat nFeat];
       
        
        % Sigma features of Luma map
        sigFeat = sigmaMapFeats(imGray);
        feat = [feat sigFeat];
        
        % Luma map's classical debiased and normalized map's features.
        dnFeat = debiasedNormalizedFeats(imGray);
        feat = [feat dnFeat];
        
        imGray = imresize(imGray,0.5);      
    end
    
    imGray=imGray1;
   
    % Features from the Yellow color channel map.
%     yFeat=yellowColorChannelMap(imGray);
%     feat = [feat yFeat];
    
    % Features from the Difference of Gaussian (DoG) of Sigma Map 
    dFeat =DoGFeat(imGray);
    feat = [feat dFeat];
      
    % Laplacian of the Luminance Map
    lFeat = lapPyramidFeats(imGray);
    feat =[feat lFeat];
end
