% Function to extract quality features from patches to be used as training
% samples for a regressor mapping the quality features to
% application-driven quality metrics. The output is a matrix where each
% row is a patch sample, the colums are the quality features, and the last
% column is the label (q_bg or q_obj depending on wether the patch
% contains background or target information respectively)

function [gT_features, gT_q_values] = gT_samples_extraction_VIIDEO(v, ...
    numOfFrames, Distortion)

path(path,'../videos')
path(path,'../bbox_configs')
path(path,'../Results')
path(path,'../functions')

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
        'coupon'};          % 17
    
% List of tests numbers that yielded the best F-score for each video
% (different background distributions)
tests_array = [2, 1, 5, 8, 5, 4, 4, 6, 1, 9, 8, 8, 7, 1, 8, 7, 1];
test = tests_array(v);

% Loading video file and parameters
load(vidName{v},'frames');
frames_pristine = frames(:,:,:,1:numOfFrames);

load(strcat('MVC_Results_Video_',num2str(v),'_pristine'),'final_objbbox');
objbbox_pristine = final_objbbox{1};
patch_width = objbbox_pristine(1,3); patch_height = objbbox_pristine(1,4);

% VIIDEO features parameters
blocksizerow = patch_height; blocksizecol = patch_width;
blockrowoverlap = 0; blockcoloverlap = 0;
filtlength = 7;

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

% Load ground-truth of the video
load(strcat(vidName{v},'_gt'),'gtP');
gtP = gtP(1:numOfFrames,:);
%numOfFrames = size(gtP,1);

% Name of the file with the initial object bounding box
bboxName = strcat('bbox_',vidName{v});

load(strcat(bboxName,'Test',num2str(test)),'bgP','binCode','points');
points = points;
Nbg  = size(bgP,1);     % Number of background patches


% Pristine case
bgP_dist_prst = zeros(Nbg, numOfFrames-1);
wait_h = waitbar(0,'Calculating metrics for pristine case');
for i = 2:numOfFrames
    waitbar(i/numOfFrames,wait_h);
    gtP_curr = gtP(i,:);
    if sum(isnan(gtP_curr))~=0
        bgP_dist_prst(:,i-1) = NaN(Nbg,1);
        continue
    end
    
    % Adjust size of ground-truth patch to match background patches
    gt_center = [gtP_curr(1)+round(gtP_curr(3)/2), gtP_curr(2)+round(gtP_curr(4)/2)];
    gtP_curr = [gt_center(1)-round(patch_width/2), gt_center(2)-round(patch_height/2), patch_width, patch_height];
    
    % Calculation of BRIEF descriptor from ground-truth object patch
    if (gtP_curr(1)+patch_width)>size(frames,2) || (gtP_curr(2)+patch_height)>size(frames,1)
        bgP_dist_prst(:,i-1) = NaN(Nbg,1);
        continue
    end

    curr_frame = double(rgb2gray(uint8(frames(:,:,:,i))));
    prev_frame = double(rgb2gray(uint8(frames(:,:,:,i-1))));
    sub_frame = curr_frame - prev_frame;
    gtP_curr(gtP_curr<=0) = 1;
    I_objP  = selectPatch(sub_frame,gtP_curr);
    objCode = briefDescriptor(I_objP,points);
    gtP_curr = gtP(i,:);
    
    % Calculation of BRIEF descriptor from all background patches
    parfor ind = 1:Nbg
        if bboxOverlapRatio(gtP_curr,bgP(ind,:))==0
            I_bgP  = selectPatch(sub_frame,bgP(ind,:));
            bgCode = briefDescriptor(I_bgP,points);
            bgP_dist_prst(ind,i) = pdist2(objCode,bgCode,'hamming');
        else
            bgP_dist_prst(ind,i) = NaN;
        end
    end
end
bgP_dist_prst(:,1) = [];
close(wait_h);

% Distortion case
gT_features = []; gT_q_values = [];

load(strcat('MVC_Results_Video_',num2str(v),'_',Distortion),'final_objbbox');
curr_bbox = final_objbbox;

q_obj = nan(length(Q),numOfFrames);
for o = 1 : length(Q)

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
    q_bg_patch = zeros(Nbg,numOfFrames);
    bg_features = zeros(28, Nbg, numOfFrames);
    for i = 2:numOfFrames
        waitbar(i/numOfFrames,wait_h);
        gtP_curr = gtP(i,:);
        
        curr_frame = double(rgb2gray(uint8(frames(:,:,:,i))));
        prev_frame = double(rgb2gray(uint8(frames(:,:,:,i-1))));
        sub_frame = curr_frame - prev_frame;

        % Resize ground truth patch from the first frame to the same size
        % of object and background patches
        gt_center = [gtP_curr(1)+round(gtP_curr(3)/2), gtP_curr(2)+round(gtP_curr(4)/2)];
        gtP_curr = [gt_center(1)-round(patch_width/2), gt_center(2)-round(patch_height/2), patch_width, patch_height];

        % Calculation of BRIEF descriptor from ground-truth object patch
        gtP_curr(gtP_curr<=0) = 1;
        I_objP  = selectPatch(sub_frame,gtP_curr);
        objCode = briefDescriptor(I_objP,points);
        gtP_curr = gtP(i,:); 
        
        % Estimation of quality metric for object bounding boxes
        if sum(isnan(curr_bbox{o}(i,:)))==0 && sum(isnan(objbbox_pristine(i,:)))==0
            q_obj(o,i) = q_obj_estimation(curr_bbox{o}(i,:),objbbox_pristine(i,:),gtP_curr);
            obj_features(i-1,:) = computeVIIDEOfeaturevector(I_objP,0, ...
                blocksizerow,blocksizecol,blockrowoverlap,blockcoloverlap,filtlength);
        else
            obj_features(i-1,:) = nan(1,size(obj_features,2));
        end        

        % Calculate q_bg for all background patches
        curr_bgP_dist_prst = bgP_dist_prst(:,i-1);
%         for ind = 1:Nbg
%             if bboxOverlapRatio(gtP_curr,bgP(ind,:))==0
%                 q_bg_patch(ind,i) = q_bg_estimation(sub_frame,curr_bgP_dist_prst(ind),bgP(ind,:),objCode,points);
%                 I_bgP  = selectPatch(sub_frame,bgP(ind,:));
%                 bg_features(:,ind,i) = computeVIIDEOfeaturevector(I_bgP,0, ...
%                     blocksizerow,blocksizecol,blockrowoverlap,blockcoloverlap,filtlength);
%             else
%                 q_bg_patch(ind,i) = NaN;
%             end
%         end
        q_bg_patch(:,i) = q_bg_estimation(sub_frame,curr_bgP_dist_prst,bgP,objCode,points);
        parfor ind=1:Nbg
            if bboxOverlapRatio(gtP_curr,bgP(ind,:))==0
                I_bgP  = selectPatch(sub_frame,bgP(ind,:));
                bg_features(:,ind,i) = computeVIIDEOfeaturevector(I_bgP,0, ...
                    blocksizerow,blocksizecol,blockrowoverlap,blockcoloverlap,filtlength);
            else
                q_bg_patch(ind,i) = NaN;
            end
        end
    end
    q_bg_patch(:,1) = [];
    bg_features(:,:,1) = [];
    q_obj(:,1) = [];
    
    bg_features = reshape(bg_features, size(bg_features,1), [])';
    q_bg_patch = reshape(q_bg_patch, [], 1);

    gT_features = [gT_features; bg_features; obj_features];
    gT_q_values = [gT_q_values; q_bg_patch; q_obj'];
end

%--------------------------------------------------------------------------
function [featvect] = computeVIIDEOfeaturevector(ydis1,ydis2, ...
    blocksizerow,blocksizecol,blockrowoverlap,blockcoloverlap,filtlength)


warning('off')
shifts          = [1 0; 0 1; 1 1; 1 -1];
window          = fspecial('gaussian',filtlength,mean(filtlength)/6);
window          = window/sum(sum(window));

featvect        = [];

%temporalsignal  = ydis1-ydis2;
temporalsignal = ydis1;


for itr =1:2
    
X                        = temporalsignal;
mu_X                     = imfilter(X,window,'replicate');
mu_sq                    = mu_X.*mu_X;
sigma_X                  = sqrt(abs(imfilter(X.*X,window,'replicate')- mu_sq));

structdis                = (X-mu_X)./(sigma_X+1);

feat                     = computefeatvect(structdis,blocksizerow,...
                           blocksizecol,blockrowoverlap,blockcoloverlap);
featvect                 = [featvect feat(:,1) (feat(:,2)+feat(:,3))/2];

for itr_shift = 1:4
    
structdis_shifted        = circshift(structdis,shifts(itr_shift,:));
feat                     = computefeatvect(structdis.*structdis_shifted, ...
                           blocksizerow,blocksizecol,...
                           blockrowoverlap,blockcoloverlap);
featvect                 = [featvect feat];

end

temporalsignal          = mu_X;

end
%--------------------------------------------------------------------------
function [feat]          = computefeatvect(structdis,blocksizerow,blocksizecol,...
                           blockrowoverlap,blockcoloverlap)
                       
featnum                  = 3;
feat                     = blkproc(structdis,[blocksizerow  blocksizecol],...
                         [ blockrowoverlap blockcoloverlap],@estimateaggdparam);
feat                     = reshape(feat,[featnum size(feat,1)*size(feat,2)/featnum]);
feat                     = feat';
feat                     = [feat(:,1) feat(:,2) feat(:,3)];


%--------------------------------------------------------------------------
function feat      = estimateaggdparam(vec)

vec                = vec(:);

if(sum(abs(vec(:))))
    
gam                = 0.2:0.01:5;
r_gam              = ((gamma(2./gam)).^2)./(gamma(1./gam).*gamma(3./gam));
leftstd            = sqrt(mean((vec(vec<0)).^2));
rightstd           = sqrt(mean((vec(vec>0)).^2));
gammahat           = leftstd/rightstd;
rhat               = (mean(abs(vec)))^2/mean((vec).^2);
rhatnorm           = (rhat*(gammahat^3 +1)*(gammahat+1))/((gammahat^2 +1)^2);
[min_difference,...
   array_position] = min((r_gam - rhatnorm).^2);
alpha              = gam(array_position);
betal              = leftstd *sqrt(gamma(1/alpha)/gamma(3/alpha));
betar              = rightstd*sqrt(gamma(1/alpha)/gamma(3/alpha));
feat               = [alpha;betal;betar];

else
    
feat               = [inf; inf ; inf];

end