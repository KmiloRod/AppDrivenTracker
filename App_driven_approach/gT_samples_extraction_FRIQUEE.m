% Function to extract FRIQUEE quality features from patches to be used as
% training samples for a classifier mapping the quality features to
% application-driven classes (suitable or non-suitable). The output is a
% matrix where each row is a patch sample, the colums are the quality
% features, and the last column is the label (1 or 0 depending on wether
% the patch is suitable or non-suitable for detection purposes)

function [training_features_obj, training_features_bg, training_labels_obj, ...
    training_labels_bg] = gT_samples_extraction_FRIQUEE(v, ...
    Distortion, varargin)
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
if nargin<3
    frames_pristine = frames;
    numOfFrames = size(frames,4);    
else
    numOfFrames = varargin{1};
    if size(frames,4) > numOfFrames
        frames_pristine = frames(:,:,:,1:numOfFrames);
    else
        frames_pristine = frames;
        numOfFrames = size(frames,4);    
    end
end

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
training_features_obj = []; training_labels_obj = [];
training_features_bg = []; training_labels_bg = [];

for o = 1 : length(Q)
%for o = 3

    % Generate distorted version of the video
    switch Distortion
        case 'MPEG4'
            [frames] = vidnoise(frames_pristine,'MPEG-4',Q(o));
            frames = uint8(frames);
        case 'Gaussian'
            [frames] = vidnoise(uint8(frames_pristine),'gaussian',[0, Q(o)]);
            frames = uint8(frames);
        case 'Blur'
            [frames] = vidnoise(uint8(frames_pristine),'blur',Q(o));
            frames = uint8(frames);
        case 'S & P'
            [frames] = vidnoise(uint8(frames_pristine),'salt & pepper',Q(o));
            frames = uint8(frames);
        case 'uneven illumination'
            [frames] = vidnoise(uint8(frames_pristine),'uneven illumination',Q(o));
            frames = uint8(frames);                
    end

    wait_h = waitbar(0,sprintf('Calculating metrics for %s distortion, level %u',Distortion,o));
    for i = 2:numOfFrames
        waitbar(i/numOfFrames,wait_h);
            
        % Subtract previous frame from current one
        if size(frames,3) == 3
            curr_frame = double(rgb2gray(uint8(frames(:,:,:,i))));
            prev_frame = double(rgb2gray(uint8(frames(:,:,:,i-1))));
        else
            curr_frame = double(frames(:,:,:,i));
            prev_frame = double(frames(:,:,:,i-1));
        end            
        sub_frame = curr_frame - prev_frame;
        %sub_frame = curr_frame;

        % Load patches selected as possible training samples from the
        % current frame and distortion level
        %current_frame_patches = training_samples{o,i};
        current_frame_patches_obj = training_samples_obj{o,i};
        current_frame_patches_bg = training_samples_bg{o,i};
        
        % If there are patches available for training in the current frame
        if ~isempty(current_frame_patches_obj)
            % Identify indexes of patches labeled as suitable
            suitable_index = find(current_frame_patches_obj(:,end));
            %non_suitable_index = find(~current_frame_patches(:,end));
            
            % Number of patches labeled as non-suitable
            num_suitable = length(suitable_index);
            num_non_suitable = size(current_frame_patches_obj,1) - num_suitable;
            %num_non_suitable = length(non_suitable_index);
            
            % If the maximum number of samples per frame was specified
            if nargin>3
                if varargin{2}>min([num_non_suitable; num_suitable])
                    samplesPerFrame = min([num_non_suitable; num_suitable]);
                else
                    samplesPerFrame = varargin{2};
                end
            else
                samplesPerFrame = min([num_non_suitable; num_suitable]);
            end

            % If there are non-suitable or suitable patches, generate
            % training samples for the current frame. If not, the current
            % frame is ignored
            if samplesPerFrame
                if ~num_suitable
                    num_suitable
                end                
                non_suitable_index = find(~current_frame_patches_obj(:,end));
                if samplesPerFrame < num_non_suitable
                    new_non_suitable = zeros(samplesPerFrame,1);

                    % Trim the number of non-suitable samples to match the
                    % number of samples per frame
                    for k = 1:samplesPerFrame
                        toRemoveIndex = round(rand*(length(non_suitable_index)-1))+1;
                        new_non_suitable(k) = non_suitable_index(toRemoveIndex);
                        non_suitable_index(toRemoveIndex) = [];                        
                    end
                    
                    % Remove the suitable sample patches with significant
                    % overlap with the non-suitable patches
%                     suitableOvlp = bboxOverlapRatio(current_frame_patches_obj(suitable_index,1:end-1),current_frame_patches_obj(new_non_suitable,1:end-1));
%                     [row, ~] = find(suitableOvlp>0.2);
%                     suitable_index(unique(row)) = [];
                    
                    % Trim the number of suitable samples to match the
                    % number of samples per frame specified as the fourth
                    % input argument
%                     for k = 1:samplesPerFrame
%                         toRemoveIndex = round(rand*(num_suitable-1))+1;
%                         new_suitable(k) = suitable_index(toRemoveIndex);
%                         suitable_index(toRemoveIndex) = [];
%                     end
                elseif isempty(non_suitable_index)
                    new_non_suitable = [];
                else
                    new_non_suitable = non_suitable_index;
                end
                
                if samplesPerFrame < num_suitable
                    new_suitable = zeros(samplesPerFrame,1);                                

                    % Remove the suitable sample patches with significant
                    % overlap with the non-suitable patches
%                     suitableOvlp = bboxOverlapRatio(current_frame_patches_obj(suitable_index,1:end-1),current_frame_patches_obj(new_non_suitable,1:end-1));
%                     [row, ~] = find(suitableOvlp>0.2);
%                     suitable_index(unique(row)) = [];

                    % Trim the number of suitable samples to match the number
                    % of non-suitable samples in order to avoid unbalance                        
                    for k = 1:samplesPerFrame
                        toRemoveIndex = round(rand*(length(suitable_index)-1))+1;
                        new_suitable(k) = suitable_index(toRemoveIndex);
                        suitable_index(toRemoveIndex) = [];                            
                    end
                elseif isempty(suitable_index)
                    new_suitable = [];
                else
                    new_suitable = suitable_index;
                end
                                                
                % Crop samples matrix
                current_frame_patches_obj = current_frame_patches_obj([new_suitable; new_non_suitable],:);                

                % Estimation of quality metric for patches, and
                % concatenation of training features and labels
                for ind = 1:size(current_frame_patches_obj,1)
                    I_objP  = selectPatch(sub_frame,current_frame_patches_obj(ind,1:4));
                    training_features_obj = [training_features_obj; friqueeLuma(I_objP)];
                    %training_features_obj = [training_features_obj; hogNSSFeat(sub_frame,current_frame_patches_obj,0,0)];
                    training_labels_obj = [training_labels_obj; current_frame_patches_obj(ind,end)];
                    %training_labels_obj = [training_labels_obj; current_frame_patches_obj(:,end)];
                end
            end
        end
        if ~isempty(current_frame_patches_bg)
            % Identify indexes of patches labeled as suitable
            suitable_index = find(current_frame_patches_bg(:,end));
            %non_suitable_index = find(~current_frame_patches_bg(:,end));
            
            % Number of patches labeled as non-suitable
            num_suitable = length(suitable_index);
            num_non_suitable = size(current_frame_patches_bg,1) - num_suitable;
            %num_non_suitable = length(non_suitable_index);
            
            % If the maximum number of samples per frame was specified
            if nargin>3
                if varargin{2}>min([num_non_suitable; num_suitable])
                    samplesPerFrame = min([num_non_suitable; num_suitable]);
                else
                    samplesPerFrame = varargin{2};
                end
            else
                samplesPerFrame = min([num_non_suitable; num_suitable]);
            end

            % If there are non-suitable patches, generate training samples
            % for the current frame. If not, the current frame is ignored
            if samplesPerFrame
                non_suitable_index = find(~current_frame_patches_bg(:,end));                
                if samplesPerFrame < num_non_suitable
                    new_non_suitable = zeros(samplesPerFrame,1);

                    % Trim the number of non-suitable samples to match the
                    % number of samples per frame specified as the fourth
                    % input argument
                    for k = 1:samplesPerFrame
                        toRemoveIndex = round(rand*(length(non_suitable_index)-1))+1;
                        new_non_suitable(k) = non_suitable_index(toRemoveIndex);
                        non_suitable_index(toRemoveIndex) = [];                        
                    end
                    
                    % Remove the suitable sample patches with significant
                    % overlap with the non-suitable patches
%                     suitableOvlp = bboxOverlapRatio(current_frame_patches_bg(suitable_index,1:end-1),current_frame_patches_bg(new_non_suitable,1:end-1));
%                     [row, ~] = find(suitableOvlp>0.2);
%                     suitable_index(unique(row)) = [];
                    
                    % Trim the number of suitable samples to match the
                    % number of samples per frame specified as the fourth
                    % input argument
%                     for k = 1:samplesPerFrame
%                         toRemoveIndex = round(rand*(length(suitable_index)-1))+1;
%                         new_suitable(k) = suitable_index(toRemoveIndex);
%                         suitable_index(toRemoveIndex) = [];
%                     end
                elseif isempty(non_suitable_index)
                    new_non_suitable = [];
                else
                    new_non_suitable = non_suitable_index;
                end

                if samplesPerFrame < num_suitable
                    new_suitable = zeros(samplesPerFrame,1); 

                    % Remove the suitable sample patches with significant
                    % overlap with the non-suitable patches
%                     suitableOvlp = bboxOverlapRatio(current_frame_patches_bg(suitable_index,1:end-1),current_frame_patches_bg(new_non_suitable,1:end-1));
%                     [row, ~] = find(suitableOvlp>0.2);
%                     suitable_index(unique(row)) = [];

                    % Trim the number of suitable samples to match the number
                    % of non-suitable samples in order to avoid unbalance                        
                    for k = 1:samplesPerFrame
                        toRemoveIndex = round(rand*(length(suitable_index)-1))+1;
                        new_suitable(k) = suitable_index(toRemoveIndex);
                        suitable_index(toRemoveIndex) = [];                            
                    end
                elseif isempty(suitable_index)
                    new_suitable = [];
                else
                    new_suitable = suitable_index;
                end

                                                
                % Crop samples matrix
                current_frame_patches_bg = current_frame_patches_bg([new_suitable; new_non_suitable],:);
                

                % Estimation of quality metric for patches, and
                % concatenation of training features and labels
                for ind = 1:size(current_frame_patches_bg,1)
                    I_bgP  = selectPatch(sub_frame,current_frame_patches_bg(ind,1:4));
                    training_features_bg = [training_features_bg; friqueeLuma(I_bgP)];
                    %training_features_bg = [training_features_bg; hogNSSFeat(sub_frame,current_frame_patches_bg,0,0)];
                    training_labels_bg = [training_labels_bg; current_frame_patches_bg(ind,end)];
                    %training_labels_bg = [training_labels_bg; current_frame_patches_bg(:,end)];
                end
            end
        end        
    end
    close(wait_h);
end
warning(w);
toc