function [q_bg_all, q_obj_all] = q_video(v, Distortion, numOfFrames)
% This function calculates the app-driven quality metrics q_bg and q_obj
% for all the background and object patches in a given video. V is a scalar
% specifying the video index, DISTORTION is a string with the name of a
% distortion applied, and NUMOFFRAMES is the desired number of frames from
% the video to be processed.
% The function outputs matrices Q_BG_ALL and Q_OBJ_ALL, which contain the
% values of the average of the q_bg metric for all the background patches
% in each frame, and the value of tyhe q_obj metric for the object patch
% from each frame respectively. Each row of the matrices corresponds to a
% level of distortion applied, and each column to a frame from the
% sequence.

path(path,'../videos')
path(path,'../bbox_configs')
path(path,'../Results')
path(path,'../functions')

% List of used videos
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
        'football'};        % 13

% Load ground-truth of the video
load(strcat(vidName{v},'_gt'),'gtP');

tests_array = [2, 1, 5, 8, 5, 4, 4, 6, 1, 9, 8, 1, 7];
test = tests_array(v);

% Load results of tracking for the pristine version of the video
load(strcat('MVC_Results_Video_',num2str(v),'_pristine'),'final_objbbox');
objbbox_pristine = final_objbbox{1};

% Name of the file with the initial object bounding box
bboxName = strcat('bbox_',vidName{v});
load(strcat(bboxName,'Test',num2str(test)),'bgP','binCode','points','CellSize','BlockSize','BlockOverlap','Numbins');
points = points;
Nbg  = size(bgP,1);     % Number of background patches
patch_width = bgP(1,3); patch_height = bgP(1,4);

% Loading video file and parameters
load(vidName{v},'frames');
if numOfFrames
    frames = frames(:,:,:,1:numOfFrames);
else
    numOfFrames = size(frames,4);
end
frames_pristine = frames;

switch Distortion
    case 'MPEG4'
        Q = [60 30 0]; % MPEG Compression
    case 'Gaussian'
        Q = [0.01, 0.05, 0.1]; % AWGN
    case 'Blur'
        Q = [5, 10, 15]; % Blur
    case 'S & P'
        Q = [0.01, 0.05, 0.1]; % S & P
    otherwise
        Q = 0;
end

% Selection of background patch for the whole video evaluation
% figure; imshow(uint8(frames(:,:,:,1)));
% h_msg = msgbox('Select the location of the background patch with double-click','Background patch','modal');
% [bg_loc_x, bg_loc_y] = getpts;
% bg_loc_x = bg_loc_x(1); bg_loc_y = bg_loc_y(1);
% bg_loc_patch = (bgP(:,1)<bg_loc_x) & (bgP(:,2)<bg_loc_y) & ((bgP(:,1)+patch_width>bg_loc_x)) & ((bgP(:,2)+patch_height>bg_loc_y));
% bg_loc_index = find(bg_loc_patch,1);
% bg_loc_patch = logical(zeros(size(bg_loc_patch))); bg_loc_patch(bg_loc_index) = 1;
% bg_patch = bgP(bg_loc_patch,:);
% close

% Pristine case
bgP_dist_prst = zeros(Nbg, numOfFrames);
bgCode = [];
wait_h = waitbar(0,'Calculating metrics for pristine case');
for i = 1:numOfFrames
    waitbar(i/numOfFrames,wait_h);
    gtP_curr = gtP(i,:);
    if sum(isnan(gtP_curr))~=0
        bgP_dist_prst(:,i) = NaN(Nbg,1);
        continue
    end
    
    % Adjust size of ground-truth patch to match background patches
    gt_center = [gtP_curr(1)+round(gtP_curr(3)/2), gtP_curr(2)+round(gtP_curr(4)/2)];
    gtP_curr = [gt_center(1)-round(patch_width/2), gt_center(2)-round(patch_height/2), patch_width, patch_height];
    
    % Calculation of BRIEF descriptor from ground-truth object patch
    if (gtP(i,1)+patch_width)>size(frames,2) || (gtP(i,2)+patch_height)>size(frames,1)
        bgP_dist_prst(:,i) = NaN(Nbg,1);
        continue
    end

    curr_frame = rgb2gray(frames(:,:,:,i));
    gtP_curr(gtP_curr<=0) = 1;
    I_objP  = selectPatch(curr_frame,gtP_curr);
    %objCode = entropy(I_objP);
%      objCode = [mean2(I_objP) std2(I_objP)];
    objCode = briefDescriptor(I_objP,points);
    gtP_curr = gtP(i,:);
    
    % Calculation of BRIEF descriptor from selected background patch
%     I_bgP  = selectPatch(frames(:,:,:,i),bg_patch);
%     bgCode = briefDescriptor(I_bgP,points);

    % Calculation of BRIEF descriptor from all background patches
    for ind = 1:Nbg
        if bboxOverlapRatio(gtP_curr,bgP(ind,:))==0
            I_bgP  = selectPatch(curr_frame,bgP(ind,:));
%             bgCode = [mean2(I_bgP) std2(I_bgP)];
            bgCode = briefDescriptor(I_bgP,points);
%             bgCode = entropy(I_bgP);
            bgP_dist_prst(ind,i) = pdist2(objCode(i,:),bgCode,'hamming');
%             bgCode = [bgCode; bgCode_ind];
%            bgP_dist_prst(ind,i) = pdist2(objCode,bgCode);
%             bgP_dist_prst(ind,i) = corr2(I_objP, I_bgP);
        else
            bgP_dist_prst(ind,i) = NaN;
        end
    end

    % Calculation of distance between BRIEF representations of ground-truth
    % target and selected background patches
%     bgP_dist_prst(i) = pdist2(objCode,bgCode,'hamming');
    
end
close(wait_h);

%q_bg_all = nan(length(Q),numOfFrames);
%q_bg_sd_all = nan(length(Q),numOfFrames);

% Distortion case
for o = 1 : length(Q)
    % Generate distorted version of the first frame
    switch Distortion
        case 'MPEG4'
            [frames] = vidnoise(frames_pristine,'MPEG-4',Q(o));
        case 'Gaussian'
            [frames] = vidnoise(uint8(frames_pristine),'gaussian',[0, Q(o)]);
        case 'Blur'
            [frames] = vidnoise(uint8(frames_pristine),'blur',Q(o));
        case 'S & P'
            [frames] = vidnoise(uint8(frames_pristine),'salt & pepper',Q(o));
    end
    
    load(strcat('MVC_Results_Video_',num2str(v),'_',Distortion),'final_objbbox');
    curr_bbox = final_objbbox;
    
    wait_h = waitbar(0,sprintf('Calculating metrics for %s distortion, level %u',Distortion,o));
    for i = 1:numOfFrames
        waitbar(i/numOfFrames,wait_h);
        gtP_curr = gtP(i,:);
        if (sum(isnan(gtP(i,:)))~=0) || (sum(isnan(bgP_dist_prst(:,i)))==Nbg)
            q_bg_all(o,i) = NaN;
            q_obj_all(o,i) = NaN;
            continue
        end
        
        % Adjust size of ground-truth patch to match background patches
        gt_center = [gtP_curr(1)+round(gtP_curr(3)/2), gtP_curr(2)+round(gtP_curr(4)/2)];
        gtP_curr = [gt_center(1)-round(patch_width/2), gt_center(2)-round(patch_height/2), patch_width, patch_height];
        
        % Convert current frame to grayscale
        curr_frame = rgb2gray(uint8(frames(:,:,:,i)));
        
        % Calculation of BRIEF descriptor from ground-truth object patch
        gtP_curr(gtP_curr<=0) = 1;
        I_objP  = selectPatch(curr_frame,gtP_curr);
%         objCode = [mean2(I_objP) std2(I_objP)];
        objCode = briefDescriptor(I_objP,points);
        %objCode = entropy(I_objP);
        gtP_curr = gtP(i,:); 
        % Estimation of quality metric for background bounding boxes
%         q_bg_all(o,i) = q_bg_estimation(I,bgP_dist_prst(i),bg_patch,objCode,points);

        % Calculate average q_bg for all background patches
        q_bg_patch = zeros(Nbg,1);
        parfor ind = 1:Nbg
            if bboxOverlapRatio(gtP_curr,bgP(ind,:))==0
                q_bg_patch(ind) = q_bg_estimation(curr_frame,bgP_dist_prst(ind,i),bgP(ind,:),objCode,points);
%                 q_bg_patch(ind) = q_bg_estimation(curr_frame,bgP_dist_prst(ind,i),bgP(ind,:),I_objP,points);
                
            else
                q_bg_patch(ind) = NaN;
            end
        end
        
%           q_bg_all(:,i,o) = q_bg_patch;
         q_bg_all(o,i) = mean(q_bg_patch, 'omitnan');
         q_bg_sd_all(o,i) = std(q_bg_patch, 'omitnan');
         
        % Estimation of quality metric for object bounding boxes
        if sum(isnan(curr_bbox{o}(i,:)))==0 && sum(isnan(objbbox_pristine(i,:)))==0
            q_obj_all(o,i) = q_obj_estimation(curr_bbox{o}(i,:),objbbox_pristine(i,:),gtP_curr);
        end
    end
    close(wait_h)
end

color_array = 'brggck';

if ~strcmp(Distortion,'pristine')
    figure; hold on
    q_bg_mean_avg = mean(q_bg_all,2,'omitnan');
    for o = 1:length(Q)
        plot(1:numOfFrames,q_bg_all(o,:),color_array(o),'DisplayName',num2str(o));
        p = plot(1:numOfFrames,ones(1,numOfFrames)*q_bg_mean_avg(o),strcat('--',color_array(o)));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end    
    hold off
    title(sprintf('q_{bg} mean, video %u, %s distortion',v,Distortion));    
%     title(sprintf('|D_{d}-D{p}| mean, video %u, %s distortion',v,Distortion));    
    plot_ax = gca;
    plot_ax.FontSize = 16;        
    xlabel('Frames');
    ylabel('q_{bg}');
    legend('show','Location','southwest');
    
    figure; hold on
    q_bg_sd_avg = mean(q_bg_sd_all,2,'omitnan');
    for o = 1:length(Q)
        plot(1:numOfFrames,q_bg_sd_all(o,:),color_array(o),'DisplayName',num2str(o));
        p = plot(1:numOfFrames,ones(1,numOfFrames)*q_bg_sd_avg(o),strcat('--',color_array(o)));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end    
    hold off
    title(sprintf('q_{bg} std. dev., video %u, %s distortion',v,Distortion));    
%     title(sprintf('|D_{d}-D{p}| std. dev., video %u, %s distortion',v,Distortion));    
    plot_ax = gca;
    plot_ax.FontSize = 16;        
    xlabel('Frames');
    ylabel('q_{bg}');
    legend('show','Location','northwest');
    
end

figure; hold on
if ~strcmp(Distortion,'pristine')
    q_obj_avg = mean(q_obj_all,2,'omitnan');
    for o = 1:length(Q)
        plot(1:numOfFrames,q_obj_all(o,:),color_array(o),'DisplayName',num2str(o));
        p = plot(1:numOfFrames,ones(1,numOfFrames)*q_obj_avg(o),strcat('--',color_array(o)));
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    hold off
    title(sprintf('q_{obj}, video %u, %s distortion',v,Distortion));
end    
plot_ax = gca;
plot_ax.FontSize = 16;        
xlabel('Frames');
ylabel('q_{obj}');
legend('show','Location','southwest');