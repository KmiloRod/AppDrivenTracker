% Function to extract FRIQUEE quality features from patches to be used as
% training samples for a classifier mapping the quality features to
% application-driven classes (suitable or non-suitable). The output is a
% matrix where each row is a patch sample, the colums are the quality
% features, and the last column is the label (1 or 0 depending on wether
% the patch is suitable or non-suitable for detection purposes)

function [trainingFeaturesObj, trainingFeaturesBg, trainingLabelsObj, ...
    trainingLabelsBg, q_obj_s, q_obj_ns, q_bg_s, q_bg_ns] = gT_samples_extraction_FRIQUEE_mix(v, ...
    numOfFrames, Distortion, ssimThresh, varargin)
tic
w = warning('off','all');

path(path,'../videos')
path(path,'../bbox_configs')
path(path,'../Results')
path(path,'../functions')
path(path,genpath('../FRIQUEE_Release'))

% List of used videos
vidName = {'car',...        % 1
        'jumping',...       % 2
        'pedestrian1',...   % 3
        'pedestrian2',...   % 4
        'pedestrian3',...   % 5
        'charger',...       % 6
        'cameraJuan',...    % 7
        'gurgaon',...       % 8
        'basketball',...    % 9
        'david',...         % 10
        'carchase',...      % 11
        'sylvester',...     % 12
        'football',...      % 13
        'crowds',...        % 14
        'cardark',...       % 15
        'bolt2',...         % 16
        'coupon',...        % 17
        'dancer2',...       % 18
        'david2',...        % 19
        'david3',...        % 20
        'faceocc1',...      % 21
        'faceocc2',...      % 22
        'fish',...          % 23
        'football1',...     % 24
        'jogging',...       % 25
        'kitesurf',...      % 26
        'man',...           % 27
        'mhyang',...        % 28
        'mountainbike',...  % 29
        'subway'};          % 30
    
% Loading video file and parameters
load(vidName{v},'frames');
if (numOfFrames == 0) || (size(frames,4) < numOfFrames)
    framesPristine = frames;
    numOfFrames = size(frames,4);    
else
    framesPristine = frames(:,:,:,1:numOfFrames);
end

tests_array = [2, 1, 5, 8, 5, 4, 4, 6, 1, 9, 8, 8, 7, 1, 8, 7, 10, 10, 9, 9, 10, 4, 5, 2, 6, 4, 4, 3, 4, 10];
test = tests_array(v);
bboxName = strcat('bbox_',vidName{v});

load(strcat(bboxName,'Test',num2str(test)),...                  % Randomly distributed background patches
   'CellSize','BlockSize','BlockOverlap','Numbins');


% Quality parameters used for generating three severity leves for each
% distortion
switch Distortion
    case 'MPEG4'
        Q = [60 30 0]; % MPEG Compression
    case 'Gaussian'
        Q = [0.01, 0.05, 0.1]; % AWGN
    case 'Blur'
        Q = [5, 10, 15]; % Blur
    case 'S & P'
        Q = [0.01, 0.05, 0.1]; % S & P
    case 'uneven illumination'
        Q = [0.00001 0.00003 0.00005];
    otherwise
        Q = 0;
end

%load(strcat('MVC_Results_Video_',num2str(v),'_',Distortion),'final_objbbox','training_samples');
load(strcat('MVC_Results_Video_objBg_',num2str(v),'_',Distortion),'final_objbbox','training_samples_obj','training_samples_bg');
trainingFeaturesObj = []; trainingLabelsObj = [];
trainingFeaturesBg = []; trainingLabelsBg = [];
currBbox = final_objbbox;
patchWidth = currBbox{1}(1,3); patchHeight = currBbox{1}(1,4);

% Load ground-truth for all the video
load(strcat(vidName{v},'_gt'),'gtP');
gtP = gtP(1:numOfFrames,:);
q_obj_s = []; q_obj_ns = [];
q_bg_s = []; q_bg_ns = [];

%for o = 1 : length(Q)
for o = 2
    
    % Generate distorted version of the video
    switch Distortion
        case 'MPEG4'
            [frames] = vidnoise(framesPristine,'MPEG-4',Q(o));
            frames = uint8(frames);
        case 'Gaussian'
            [frames] = vidnoise(uint8(framesPristine),'gaussian',[0, Q(o)]);
            frames = uint8(frames);
        case 'Blur'
            [frames] = vidnoise(uint8(framesPristine),'blur',Q(o));
            frames = uint8(frames);
        case 'S & P'
            [frames] = vidnoise(uint8(framesPristine),'salt & pepper',Q(o));
            frames = uint8(frames);
        case 'uneven illumination'
            [frames] = vidnoise(uint8(framesPristine),'uneven illumination',Q(o));
            frames = uint8(frames);                
    end

    wait_h = waitbar(0,sprintf('Calculating metrics for %s distortion, level %u',Distortion,o));
    for i = 2:numOfFrames
        waitbar(i/numOfFrames,wait_h);
        
        % Load ground-truth bounding box for current frame
        gtPCurr = gtP(i,:);
            
        % Subtract previous frame from current one
        if size(frames,3) == 3
            currFrame = double(rgb2gray(uint8(frames(:,:,:,i))));
            %prevFrame = double(rgb2gray(uint8(frames(:,:,:,i-1))));
        else
            currFrame = double(frames(:,:,:,i));
            %prevFrame = double(frames(:,:,:,i-1));
        end            
        %subFrame = currFrame - prevFrame;
        subFrame = currFrame;

        % Load patches selected as possible training samples from the
        % current frame and distortion level
        %currentFramePatches = training_samples{o,i};
        currentFramePatchesObj = training_samples_obj{o,i};
        currentFramePatchesBg = training_samples_bg{o,i};

        % Resize ground truth patch from the first frame to the same size
        % of object and background patches
        gtCenter = [gtPCurr(1,1)+round(gtPCurr(1,3)/2), gtPCurr(1,2)+round(gtPCurr(1,4)/2)];
        gtPCurr = [gtCenter(1)-round(patchWidth/2), gtCenter(2)-round(patchHeight/2), patchWidth, patchHeight];        
        
        % If gtP exists, load the ground-truth patch image in IgtP
        if sum(isnan(gtPCurr))==0 && isBboxInBounds(gtPCurr, size(subFrame))
            IgtP = selectPatch(subFrame,gtPCurr);
        end
        
        %%%%%% OBJECT PATCHES %%%%%%%%
        % If there are object patches available for training in the current
        % frame
        if ~isempty(currentFramePatchesObj)
            % Identify indexes of patches labeled as suitable
            suitableIndex = find(currentFramePatchesObj(:,end));
            %nonSuitableIndex = find(~currentFramePatches(:,end));
            
            % Number of patches labeled as non-suitable
            numSuitable = length(suitableIndex);
            numNonSuitable = size(currentFramePatchesObj,1) - numSuitable;
            %numNonSuitable = length(nonSuitableIndex);
            
            % If the maximum number of samples per frame was specified
            if nargin>4
                if varargin{1}>min([numNonSuitable; numSuitable])
                    samplesPerFrame = min([numNonSuitable; numSuitable]);
                else
                    samplesPerFrame = varargin{1};
                end
            else
                samplesPerFrame = min([numNonSuitable; numSuitable]);
            end

            % If there are non-suitable or suitable patches, generate
            % training samples for the current frame. If not, the current
            % frame is ignored
            if samplesPerFrame
                nonSuitableIndex = find(~currentFramePatchesObj(:,end));

                % Sub-sample 'non-suitable' set
                if samplesPerFrame < numNonSuitable
                    newNonSuitable = zeros(samplesPerFrame,1);

                    % Trim the number of non-suitable samples to match the
                    % number of samples per frame
                    for k = 1:samplesPerFrame
                        toRemoveIndex = round(rand*(length(nonSuitableIndex)-1))+1;
                        newNonSuitable(k) = nonSuitableIndex(toRemoveIndex);
                        nonSuitableIndex(toRemoveIndex) = [];                        
                    end

                    % Select samplesPerFrame patches as training samples
%                     for k = 1:samplesPerFrame
%                         tempIndex = round(rand*(length(nonSuitableIndex)-1))+1;
%                         toAddIndex = nonSuitableIndex(tempIndex);
%                         newNonSuitable(k) = toAddIndex;
%                         nonSuitableIndex(tempIndex) = [];                            
%                     end                    
                                        
                elseif isempty(nonSuitableIndex)
                    newNonSuitable = [];
                else
                    newNonSuitable = nonSuitableIndex;
                end
                
                % Sub-sample 'suitable' set
                if samplesPerFrame < numSuitable
                    newSuitable = zeros(samplesPerFrame,1);  
                
                    % Select samplesPerFrame patches as training samples
%                 for k = 1:samplesPerFrame
%                     q = 1;
%                     while q < ssimThresh
%                         tempIndex = round(rand*(length(suitableIndex)-1))+1;
%                         toAddIndex = suitableIndex(tempIndex);
% 
%                         IobjP  = selectPatch(subFrame,currentFramePatchesObj(toAddIndex,1:4));                        
%                         if sum(isnan(gtPCurr))==0 && isBboxInBounds(gtPCurr, size(subFrame))
%                             q = cwssim_index(IobjP, IgtP, 2, 16, 0, 0);
%                         else
%                             suitableIndex(tempIndex) = [];
%                             break
%                         end
%                         suitableIndex(tempIndex) = [];
%                     end
%                     newSuitable(k) = toAddIndex;
%                 end                    

                    % Remove the suitable sample patches with significant
                    % overlap with the non-suitable patches
%                     suitableOvlp = bboxOverlapRatio(currentFramePatchesObj(suitableIndex,1:end-1),currentFramePatchesObj(newNonSuitable,1:end-1));
%                     [row, ~] = find(suitableOvlp>0.2);
%                     suitableIndex(unique(row)) = [];

                    % Trim the number of suitable samples to match the number
                    % of samples per frame
                    for k = 1:samplesPerFrame
                        toRemoveIndex = round(rand*(length(suitableIndex)-1))+1;
                        newSuitable(k) = suitableIndex(toRemoveIndex);
                        suitableIndex(toRemoveIndex) = [];                            
                    end
                    
                elseif isempty(suitableIndex)
                    newSuitable = [];
                else
                    newSuitable = suitableIndex;
                end
                        
%                 % If a ground-truth patch exists for the current frame,
%                 % check the similarity of the 'suitable' object patches
%                 % with it and change their label to 'non-suitable' if the
%                 % similarity measure q is below the ssimThresh threshold
%                 if sum(isnan(gtPCurr))==0 && isBboxInBounds(gtPCurr, size(subFrame))
%                     numSuitable = length(newSuitable);
%                     for k = 1:numSuitable
%                         tempIndex = newSuitable(k);
%                         IobjP  = selectPatch(subFrame,currentFramePatchesObj(tempIndex,1:4));
%                         q = cwssim_index(IobjP, IgtP, 2, 16, 0, 0);
%                         if q < ssimThresh
%                             newNonSuitable = [newNonSuitable; tempIndex];
%                             currentFramePatchesObj(tempIndex,end) = 0;
%                             newSuitable(k) = NaN;
%                         end
%                     end
%                     newSuitable(isnan(newSuitable))=[];
%                     %numSuitable = length(suitableIndex);
%                 end

                % If a ground-truth patch exists for the current frame,
                % check the similarity of the 'non-suitable' object patches
                % with it and change their label to 'suitable' if the
                % similarity measure q is above the ssimThresh threshold
                if sum(isnan(gtPCurr))==0 && isBboxInBounds(gtPCurr, size(subFrame))
                    numNonSuitable = length(newNonSuitable);
                    for k = 1:numNonSuitable
                        tempIndex = newNonSuitable(k);
                        IobjP  = selectPatch(subFrame,currentFramePatchesObj(tempIndex,1:4));
                        q = cwssim_index(IobjP, IgtP, 2, 16, 0, 0);
                        if q > ssimThresh
                            newSuitable = [newSuitable; tempIndex];
                            currentFramePatchesObj(tempIndex,end) = 1;
                            newNonSuitable(k) = NaN;
                        end
                    end
                    newNonSuitable(isnan(newNonSuitable))=[];
                    %numSuitable = length(suitableIndex);
                end

                
                % Crop samples matrix
                currentFramePatchesObj = currentFramePatchesObj([newSuitable; newNonSuitable],:);                

                bgP_curr = round(rand*size(currentFramePatchesBg,1)+1)-1;
                
                % Estimation of quality metric for patches, and
                % concatenation of training features and labels
                for ind = 1:size(currentFramePatchesObj,1)
                     IobjP  = selectPatch(subFrame,currentFramePatchesObj(ind,1:4));
                     IbgP  = selectPatch(subFrame,currentFramePatchesBg(bgP_curr,1:4));
                    
% %                     q_obj = cwssim_index(IobjP, IgtP, 2, 16, 0, 0);
%                     q_obj = cwssim_feats(IobjP, 2, 16, 0, 0);
% %                    q_obj = [mean2(IobjP), std2(IobjP)];
%                     if currentFramePatchesObj(ind,end)==1
%                         q_obj_s = [q_obj_s; q_obj];
%                     else
%                         q_obj_ns = [q_obj_ns; q_obj];
%                     end

%                     objP_feats = hogNSSFeat(subFrame,currentFramePatchesObj(ind,1:4),0,0);
%                     bgP_feats = hogNSSFeat(subFrame,currentFramePatchesBg(bgP_curr,1:4),0,0);
%                      objP_feats = sred_estimation(IobjP-IbgP, 4, 3, 6, 2, 0.1);
                     %bgP_feats = sred_estimation(IbgP, 4, 3, 6, 2, 0.1);
%                      objP_feats = friqueeLuma(IobjP);
%                     objP_feats = [debiasedNormalizedFeats(IobjP-IbgP) mean2(IobjP-IbgP) std2(IobjP-IbgP)];
                    
                    %MSCN_feats = pdist2(debiasedNormalizedFeats(IobjP), debiasedNormalizedFeats(IbgP));
                    MSCN_feats = debiasedNormalizedFeats(IobjP);
                    %sred_feats = pdist2(sred_estimation(IobjP, 4, 3, 6, 2, 0.1), sred_estimation(IbgP, 4, 3, 6, 2, 0.1));
                    sred_feats = sred_estimation(IobjP, 4, 3, 6, 2, 0.1);
                    %HOG_feats = pdist2(hogNSSFeat(IobjP,[1,1,size(IobjP,2),size(IobjP,1)],0,0),...
                    %    hogNSSFeat(IbgP,[1,1,size(IbgP,2),size(IbgP,1)],0,0));
                    HOG_feats = hogNSSFeat(IobjP,[1,1,size(IobjP,2),size(IobjP,1)],0,0);
                    objP_feats = [MSCN_feats, HOG_feats, sred_feats];
                    
                    %bgP_feats = [debiasedNormalizedFeats(IbgP) mean2(IbgP) std2(IbgP)];
                    
%                      diff_HOG = hogNSSFeat(IobjP-IbgP,[1,1,size(IobjP,2),size(IobjP,1)],0,0);
                    
                    %trainingFeaturesObj = [trainingFeaturesObj; (objP_feats-bgP_feats).^2];
                    trainingFeaturesObj = [trainingFeaturesObj; objP_feats];
                    %trainingFeaturesObj = [trainingFeaturesObj; friqueeLuma(IobjP)];
                    %trainingFeaturesObj = [trainingFeaturesObj; []]; % For testing
                    trainingLabelsObj = [trainingLabelsObj; currentFramePatchesObj(ind,end)];
                end
            end
        end
        
        %%%%%% BACKGROUND PATCHES %%%%%%%%
        % If there are background patches available for training in the
        % current frame
        if ~isempty(currentFramePatchesBg)
            % Identify indexes of patches labeled as suitable
            suitableIndex = find(currentFramePatchesBg(:,end));
            %nonSuitableIndex = find(~currentFramePatchesBg(:,end));
            
            % Number of patches labeled as non-suitable
            numSuitable = length(suitableIndex);
            numNonSuitable = size(currentFramePatchesBg,1) - numSuitable;
            %numNonSuitable = length(nonSuitableIndex);
            
            % If the maximum number of samples per frame was specified
            if nargin>4
                if varargin{1}>min([numNonSuitable; numSuitable])
                    samplesPerFrame = min([numNonSuitable; numSuitable]);
                else
                    samplesPerFrame = varargin{1};
                end
            else
                samplesPerFrame = min([numNonSuitable; numSuitable]);
            end

            % If there are non-suitable patches, generate training samples
            % for the current frame. If not, the current frame is ignored
            if samplesPerFrame
                nonSuitableIndex = find(~currentFramePatchesBg(:,end));                
                if samplesPerFrame < numNonSuitable
                    newNonSuitable = zeros(samplesPerFrame,1);

                    % Trim the number of non-suitable samples to match the
                    % number of samples per frame specified as the fourth
                    % input argument
                    for k = 1:samplesPerFrame
                        toRemoveIndex = round(rand*(length(nonSuitableIndex)-1))+1;
                        newNonSuitable(k) = nonSuitableIndex(toRemoveIndex);
                        nonSuitableIndex(toRemoveIndex) = [];                        
                    end
                    
                    % Remove the suitable sample patches with significant
                    % overlap with the non-suitable patches
%                     suitableOvlp = bboxOverlapRatio(currentFramePatchesBg(suitableIndex,1:end-1),currentFramePatchesBg(newNonSuitable,1:end-1));
%                     [row, ~] = find(suitableOvlp>0.2);
%                     suitableIndex(unique(row)) = [];
                    
                elseif isempty(nonSuitableIndex)
                    newNonSuitable = [];
                else
                    newNonSuitable = nonSuitableIndex;
                end        

                if samplesPerFrame < numSuitable
                    newSuitable = zeros(samplesPerFrame,1); 

                    % Remove the suitable sample patches with significant
                    % overlap with the non-suitable patches
%                     suitableOvlp = bboxOverlapRatio(currentFramePatchesBg(suitableIndex,1:end-1),currentFramePatchesBg(newNonSuitable,1:end-1));
%                     [row, ~] = find(suitableOvlp>0.2);
%                     suitableIndex(unique(row)) = [];

                    % Trim the number of suitable samples to match the number
                    % of non-suitable samples in order to avoid unbalance                        
                    for k = 1:samplesPerFrame
                        toRemoveIndex = round(rand*(length(suitableIndex)-1))+1;
                        newSuitable(k) = suitableIndex(toRemoveIndex);
                        suitableIndex(toRemoveIndex) = [];                            
                    end
                elseif isempty(suitableIndex)
                    newSuitable = [];
                else
                    newSuitable = suitableIndex;
                end

                % If a ground-truth patch exists for the current frame,
                % check the similarity of the 'suitable' background patches
                % with it and change their label to 'non-suitable' if the
                % similarity measure q is above the ssimThresh threshold
                if sum(isnan(gtPCurr))==0 && isBboxInBounds(gtPCurr, size(subFrame))
                    numSuitable = length(newSuitable);
                    for k = 1:numSuitable
                        tempIndex = newSuitable(k);
                        IobjP  = selectPatch(subFrame,currentFramePatchesBg(tempIndex,1:4));
                        q = cwssim_index(IobjP, IgtP, 2, 16, 0, 0);
                        if q > ssimThresh
                            newNonSuitable = [newNonSuitable; tempIndex];
                            currentFramePatchesBg(tempIndex,end) = 0;
                            newSuitable(k) = NaN;
                        end
                    end
                    newSuitable(isnan(newSuitable))=[];
                    %numSuitable = length(suitableIndex);
                end
                
                % Crop samples matrix
                currentFramePatchesBg = currentFramePatchesBg([newSuitable; newNonSuitable],:);
                
                % Estimation of quality metric for patches, and
                % concatenation of training features and labels
                for ind = 1:size(currentFramePatchesBg,1)
                    IbgP  = selectPatch(subFrame,currentFramePatchesBg(ind,1:4));

%                     q_bg= cwssim_index(IobjP, IgtP, 2, 16, 0, 0);
%                     if currentFramePatchesBg(ind,end)==1
%                         q_bg_s = [q_bg_s; q_bg];
%                     else
%                         q_bg_ns = [q_bg_ns; q_bg];
%                     end                    
                    
                    %trainingFeaturesBg = [trainingFeaturesBg; friqueeLuma(IbgP)];
                    trainingFeaturesBg = [trainingFeaturesBg; []]; % For testing
                    trainingLabelsBg = [trainingLabelsBg; currentFramePatchesBg(ind,end)];
                end
            end
        end        
    end
    close(wait_h);
end
[~,q_obj_s,latent_s] = pca(q_obj_s, 'NumComponents', 3);
[~,q_obj_ns,latent_ns] = pca(q_obj_ns, 'NumComponents', 3);

warning(w);
toc