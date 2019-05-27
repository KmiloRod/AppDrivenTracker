% Ing. Carlos Fernando Quiroga Ruiz 22/Apr/2019
% This function directly calculates the HOG or NSS or both characteristics for a complete video.
% The function has as input parameters:
% - numOfFrames: Is the number of frames that the video has (int)
% - patchFrame: These are the patches per frame that you want to analyze (cell)
% to see how this arrangement is built, look at the "videoPatch" function
% - frames_pristine: These are the pristine frames of the whole video (cell)
% - frames_distored: Are the arrangements of the distorted video (cell)
% to see how this data set is built see function "distoredDataset".
% - charac: indicates what type of feature is to be calculated if (HOG = 1), (NSS = 2) or (HOG and NSS = 3) (int)
% 
% the function has output parameters:
% 
% - hognss: These are the HOG or NSS features, depending on what has been chosen. (cell)
% - k: Frames to which features are not calculated.

function [hognss, k]=hog_nss(numOfFrames,patchFrame,frames_pristine,frames_distored, charac,Norm)
    
    n = 0;
    if Norm
        n = 1;
    end
    switch charac
        case 1
        %-------Calculation of the HOGs for the pristine and distorted frames-----
            j=1;
            k=[];% frames to which the HOG characteristics were not calculated
            for i = 1:numOfFrames
                porcentage=ceil(i*100/numOfFrames)
                hog_distored{j}=[];

                if isempty(patchFrame{i}) == 0
                    hog_pristine{j} = hogNSSFeat(frames_pristine{i},patchFrame{i},0,1,n);

                    for d = 1 : size(frames_distored{i},2)
                        hog_d = hogNSSFeat(frames_distored{i}{d},patchFrame{i},0,1,n);
                        hog_distored{j}=cat(1,hog_distored{j},hog_d);
                    end

                    hognss{j}=[hog_pristine{j};hog_distored{j}];

                    %imshow(uint8((hog{j}/max(max(hog{j})))*255))

                    j=j+1;
                else
                    k=cat(1,k,i);
                end     
            end
        case 2
        %-------Calculation of the NSS for the pristine and distorted frames-----
            j=1;
            k=[];% frames to which the NSS characteristics were not calculated
            for i = 1:numOfFrames
                porcentage=ceil(i*100/numOfFrames)
                nss_distored=[];

                if isempty(patchFrame{i}) == 0
                    nss_p = hogNSSFeat(frames_pristine{i},patchFrame{i},1,1,n);
                    nss_pristine=nss_p(:,size(nss_p,2)-35:size(nss_p,2));
                    for d = 1 : size(frames_distored{i},2)
                        nss_d = hogNSSFeat(frames_distored{i}{d},patchFrame{i},1,1,n);
                        nss_distored=cat(1,nss_distored,nss_d(:,size(nss_p,2)-35:size(nss_p,2)));
                    end

                    hognss{j}=[nss_pristine;nss_distored];

                    %imshow(uint8((hog{j}/max(max(hog{j})))*255))

                    j=j+1;
                else
                    k=cat(1,k,i);
                end     
            end
        case 3
        %-------Calculation of the HOG and NSS for the pristine and distorted frames-----
            j=1;
            k=[];% frames to which the NSS characteristics were not calculated
            for i = 1:numOfFrames
                porcentage=ceil(i*100/numOfFrames)
                nss_distored=[];

                if isempty(patchFrame{i}) == 0
                    nss_p = hogNSSFeat(frames_pristine{i},patchFrame{i},1,1,n);
                    nss_pristine=nss_p;
                    for d = 1 : size(frames_distored{i},2)
                        nss_d = hogNSSFeat(frames_distored{i}{d},patchFrame{i},1,1,n);
                        nss_distored=cat(1,nss_distored,nss_d);
                    end

                    hognss{j}=[nss_pristine;nss_distored];

                    %imshow(uint8((hog{j}/max(max(hog{j})))*255))

                    j=j+1;
                else
                    k=cat(1,k,i);
                end     
            end
        case 4
        %------Calculation of the HOG normalized zscore characteristics for 
      
        otherwise
    end
end