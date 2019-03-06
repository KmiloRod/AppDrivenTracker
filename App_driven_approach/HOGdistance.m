function [gtP_HOG_dist] = HOGdistance(v, Distortion, numOfFrames)
% Function to calculate distance between HOG representations of
% ground-truth patches and background patches in the first frame of the
% training videos

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
    
tests_array = [2, 1, 5, 8, 5, 4, 4, 6, 1, 9, 8, 8, 7, 1, 8, 7, 10, 10, 9, 9, 10, 4, 5, 2, 6, 4, 4, 3, 4, 10];


% Quality parameters used for generating eight severity leves for each
% distortion
switch Distortion
    case 'MPEG4'
        Q = [60 50 40 30 20 10 5 0]; % MPEG Compression
    case 'Gaussian'
        Q = [0.01, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.1]; % AWGN
    case 'Blur'
        Q = [1, 3, 5, 7, 9, 11, 13, 15]; % Blur
    case 'S & P'
        Q = [0.01, 0.02, 0.03, 0.05, 0.1]; % S & P
    case 'uneven illumination'
        Q = [0.00001 0.00003 0.00005];
    otherwise
        Q = 0;
end

%gtP_HOG_dist = zeros(length(v), length(Q));    
gtP_HOG_dist = [];    

wait_h = waitbar(0,'Calculating distances');

for vid = v
    waitbar(find(vid==v)/length(v),wait_h,strcat('Calculating distances for video ',num2str(vid)));
    test = tests_array(vid);
    % Name of the file with the initial object bounding box
    bboxName = strcat('bbox_',vidName{vid});

    % Load ground-truth of the video
    load(strcat(vidName{vid},'_gt'),'gtP');
    % Load variables for the video (object and background boxes, etc.)
    load(strcat(bboxName,'Test',num2str(test)),...                  % Randomly distributed background patches
       'objP','bgP','objbbox','context','bgKeys',...
       'binCode','points','bgTsh4',...
       'CellSize','BlockSize','BlockOverlap','Numbins','N_HOG');
    patch_width = objbbox(1,3); patch_height = objbbox(1,4);

    % Loading video file and parameters
    load(vidName{vid},'frames');
    if numOfFrames
        frames = frames(:,:,:,1:numOfFrames);
    else
        numOfFrames = size(frames,4);
    end
    frames_pristine = frames;

    % Pristine case
    if size(frames,3)==3
        curr_frame = double(rgb2gray(uint8(frames(:,:,:,1))));
    else
        curr_frame = double(frames(:,:,:,1));
    end
    
    % Resize ground truth patch from the first frame to the same size
    % of object and background patches
    gt_center = [gtP(1,1)+round(gtP(1,3)/2), gtP(1,2)+round(gtP(1,4)/2)];
    gtP(1,:) = [gt_center(1)-round(patch_width/2), gt_center(2)-round(patch_height/2), patch_width, patch_height];
    gtP_curr = gtP(1,:);

    bgP_curr = round(rand*size(bgP,1));
    gtP_HOG_prst = hogNSSFeat(curr_frame,gtP_curr,0,0);
    gtP_HOG_prst_bG = hogNSSFeat(curr_frame,bgP(bgP_curr,:),0,0);

    %gtP_HOG_dist_v = zeros(1,length(Q));
    gtP_HOG_dist_v = zeros(1,length(Q)+1);
    gtP_HOG_dist_v(1) = mean(pdist2(gtP_HOG_prst_bG, gtP_HOG_prst, 'euclidean'));
    
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

        if size(frames,3)==3
            curr_frame = double(rgb2gray(uint8(frames(:,:,:,1))));
        else
            curr_frame = double(frames(:,:,:,1));
        end

        gtP_HOG_dstr = hogNSSFeat(curr_frame,gtP_curr,0,0);
        gtP_HOG_dstr_bG = hogNSSFeat(curr_frame,bgP(bgP_curr,:),0,0);

        %gtP_HOG_dist_v(o) = pdist2(gtP_HOG_dstr, gtP_HOG_prst, 'euclidean');
        gtP_HOG_dist_v(o+1) = mean(pdist2(gtP_HOG_dstr, gtP_HOG_dstr_bG, 'euclidean'));
    end
    gtP_HOG_dist = [gtP_HOG_dist; gtP_HOG_dist_v];
end

close(wait_h);

color_array = 'brgyck';

    figure; hold on
    if length(v)>1
        for vid = 1:length(v)
            %plot(1:length(Q),gtP_HOG_dist(vid,:),color_array(vid),'DisplayName',strcat('Video # ',num2str(v(vid))));
            plot(1:length(Q)+1,gtP_HOG_dist(vid,:),color_array(vid),'DisplayName',strcat('Video # ',num2str(v(vid))));
        end    
    else
        %plot(1:length(Q),gtP_HOG_dist,color_array(v),'DisplayName',strcat('Video # ',num2str(v)));
        plot(1:length(Q)+1,gtP_HOG_dist,color_array(v),'DisplayName',strcat('Video # ',num2str(v)));
    end
    hold off
    %title(sprintf('HOG euclidean distance between pristine and distorted\n ground-truth patch with %s',Distortion));
    title(sprintf('Mean HOG euclidean distance between ground-truth\n and background patches with %s',Distortion));
    plot_ax = gca;
    plot_ax.FontSize = 16;        
    xlabel('Distortion level');
    ylabel('Distance');
    legend('show','Location','northwest'); 
end