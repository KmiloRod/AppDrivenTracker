function Test_ROC_AOS_MVC_testsBg(v,Display)
% Generates success plots from the tracker performance on the video number
% v affected by three levels of the distortion of image quality specified
% by the string Distortion ('pristine', 'MPEG4', 'Gaussian', 'S & P' or
% 'Blur'). Generates tests results files with 10 different random
% background patches distribution.

path(path,'./functions')
path(path,'./MeanShift_Code')
path(path,'./bbox_configs')
path(path,'./matlab')
path(path,'./videos')

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

global BlockSize BlockOverlap CellSize Numbins

% Array of AOS threshold values for generating success plots
%AOS_threshold_array = linspace(0.1,1,19);
AOS_threshold_array = linspace(0,1,100);
location_threshold_array = linspace(0,50,100);

tic

%     % Quality parameters used for generating three severity leves for each
%     % distortion
%     switch Distortion
%         case 'MPEG4'
%             Q = [60 30 0]; % MPEG Compression
%         case 'Gaussian'
%             Q = [0.01, 0.05, 0.1]; % AWGN
%         case 'Blur'
%             Q = [5, 10, 15]; % Blur
%         case 'S & P'
%             Q = [0.01, 0.05, 0.1]; % S & P
%         otherwise
%             Q = 0;
%     end

% Loading video file and parameters
load(vidName{v},'frames');
%    frames_pristine = frames;
numOfFrames = size(frames,4);
Height = size(frames,1);
width = size(frames,2);
imSize = [Height,width];

ovrlp = 1/4; %[1/2 1/3 1/4 1/5];
    
predict_accuracy = zeros(1,numOfFrames);    

% Test for each level of distortion
%     for o = 1 : length(Q) 

    % Generate distorted version of the video
%         switch Distortion
%             case 'MPEG4'
%                 [frames] = vidnoise(frames_pristine,'MPEG-4',Q(o));
%                 frames = uint8(frames);
%             case 'Gaussian'
%                 [frames] = vidnoise(uint8(frames_pristine),'gaussian',[0, Q(o)]);
%                 frames = uint8(frames);
%             case 'Blur'
%                 [frames] = vidnoise(uint8(frames_pristine),'blur',Q(o));
%                 frames = uint8(frames);
%             case 'S & P'
%                 [frames] = vidnoise(uint8(frames_pristine),'salt & pepper',Q(o));
%                 frames = uint8(frames);
%         end

% Load ground-truth of the video
load(strcat(vidName{v},'_gt'),'gtP');

% Name of the file with the initial object bounding box
bboxName = strcat('bbox_',vidName{v});

fig_SP = figure('Name',sprintf('Success plots, video %u',v),'NumberTitle','off','Visible','off');
fig_PP = figure('Name',sprintf('Precision plots, video %u',v),'NumberTitle','off','Visible','off');

for test = 1:10
    % If no initial bounding box, the user has to select it manually
    if ~exist(strcat(bboxName,'.mat'),'file')
        figure;
        imshow(uint8(frames(:,:,:,1)),'InitialMagnification',150);
        h     = msgbox('Select the object-square region by clicking and dragging','Object Square','modal');
        objbbox = floor(getrect);
        save(bboxName,'objbbox');
        close;
    else
        load(bboxName,'objbbox');
    end
        
    % Para generar los tests
    [objP,context,bgP,bgKeys,binCode,points,bgTsh4,...
    CellSize,BlockSize,...
    BlockOverlap,Numbins,N_HOG] = FBTandMSTInit(objbbox,frames(:,:,:,1));
%    save(strcat(bboxName,'Test',num2str(test)),...
%        'objP','bgP','objbbox','context','bgKeys',...
%        'binCode','points','bgTsh4',...
%        'CellSize','BlockSize','BlockOverlap','Numbins','N_HOG');

%     % Load variables for the video (object and background boxes, etc.)
%     load(strcat(bboxName,'Test',num2str(test)),...
%        'objP','bgP','objbbox','context','bgKeys',...
%        'binCode','points','bgTsh4',...
%        'CellSize','BlockSize','BlockOverlap','Numbins','N_HOG');
    Nbg  = size(bgP,1);     % Number of background patches
    Nobj = size(objP,1);    % Number of object patches
    Nobj_max = N_HOG - Nbg; % Maximum number of possible object patches

    % Update objbbox to make patch sizes match
    objbbox = objP(1,:);

    % MST params
    index_start = 1;
    % Similarity Threshold
    f_thresh = 0.16;
    % Number max of iterations to converge
    max_it = 5;
    % Parzen window parameters
    kernel_type = 'Gaussian';
    radius      = 1;
    % Calculation of the Parzen Kernel window
    [k,gx,gy] = Parzen_window(objbbox(1,4),objbbox(1,3),radius,kernel_type,0);

    if size(frames,3)==3
        I = double(rgb2gray(uint8(frames(:,:,:,1))));
    else
        I = double(frames(:,:,:,1));
    end
    bgPVar = patchVariance(I,bgP);

    % Initial sliding window patches
    wP = slidingWindow(1,1,imSize(2),imSize(1),objbbox(3),objbbox(4),ovrlp);
    objFrames = ones(Nobj,1);
    object_found = zeros(1,numOfFrames);

    % Display the video frames during processing
    if Display
        figure; imshow(uint8(drawPatches(frames(:,:,:,1),objbbox(1,:),1)));
    end
    objboxdraw = objbbox(1,:);

    % Extraction of HOG features from all the patches
    hogS   = hogNSSFeat(I,[objP;bgP],0,0);

    % Averages of HOG features for object and background patches
    hogSobj_avg = mean(hogS(1:Nobj,:));
    hogSbg_avg  = mean(hogS(Nobj+1:Nobj+Nbg,:));

    % Euclidean distances between object and bg HOG features to the average
    dist1 = pdist2(hogS(1:Nobj,:),hogSobj_avg);
    dist2 = pdist2(hogS(Nobj+1:Nobj+Nbg,:),hogSbg_avg);
    [dist1_,Idist1] = sort(dist1,'ascend');
    [~,Idist2] = sort(dist2,'ascend');

    % Sort HOG features
    hogS(1:Nobj,:) = hogS(Idist1,:);
    hogS(Nobj+1:Nobj+Nbg,:) = hogS(Idist2+Nobj,:);

    %bgKeys = bgKeys(Idist2);
    bgP = bgP(Idist2,:);
    bgPVar = bgPVar(Idist2);

    % Training of SVM classifier
    model = svmtrain2([ones(Nobj,1);zeros(Nbg,1)],double(hogS),'-t 0 -c 100');
    % Accuracy of SVM classifier prediction
    [~, accuracy_L, ~] = svmpredict2([ones(Nobj,1);zeros(Nbg,1)],hogS,model);
    predict_accuracy(1) = accuracy_L(1)/100;

    % Neighbouring window for object search
    D = searchWindow(objbbox);

    flag = zeros(1,size(frames,4));     % MST flag
    objbbox = zeros(size(frames,4),4);
    objbbox(1,:) = objP(1,:);
    Length = size(frames,4);

    % Resize ground truth patch from the first frame to the same size
    % of object and background patches
%     patch_width = objbbox(1,3); patch_height = objbbox(1,4);            
%     gt_center = [gtP(1,1)+round(gtP(1,3)/2), gtP(1,2)+round(gtP(1,4)/2)];
%     gtP(1,:) = [gt_center(1)-round(patch_width/2), gt_center(2)-round(patch_height/2), patch_width, patch_height];

    % Loops from the second frame to the end
    for i = 2 : size(frames,4)
        i

        % Convert current frame to grayscale
        if size(frames,3)==3
            I = double(rgb2gray(uint8(frames(:,:,:,i))));
        else
            I = double(frames(:,:,:,i));
        end

        % If the object was detected in the previous frame, search in the
        % neighbouring window
        if sum(isnan(objbbox(i-1,:)))==0
            bbox = ones(size(D,1),1)*objbbox(i-1,:) + D; % posible bboxes where the object is located in frame t + 1
            % Remove boxes outside the frame
            bbox(bbox(:,1)<1 | bbox(:,2)<1 | (bbox(:,1)+bbox(:,3)-1)>width | (bbox(:,2)+bbox(:,4)-1)>Height,:)=[];

%             hogS_nxt = hogFeat(I,bbox); % HOG features of the window boxes

            % HOG features of the window boxes
            hogS_nxt   = hogNSSFeat(I,bbox,0,0);            

            % If there is ground-truth for the current frame
            if isempty(find(isnan(gtP(i,:)), 1))
                % Adjust size of ground-truth patch to match object patches
%                 gt_center = [gtP(i,1)+round(gtP(i,3)/2), gtP(i,2)+round(gtP(i,4)/2)];
%                 gtP(i,:) = [gt_center(1)-round(patch_width/2), gt_center(2)-round(patch_height/2), patch_width, patch_height];

                % Label as matches the window patches with overlap greater
                % than 0.7 with the ground-truth for accuracy estimation
                labels_gt = bboxOverlapRatio(gtP(i,:),bbox)>=0.7;

                % SVM classifier prediction
                [labels, ~, ~] = svmpredict2(double(labels_gt'),hogS_nxt,model);
                predict_accuracy(i) = length(find(labels(labels_gt)))/length(find(labels_gt));

            % If there is no ground-truth for the current frame, does not
            % calculate prediction accuracy
            else                
                [labels, ~, ~] = svmpredict2(ones(size(bbox,1),1),hogS_nxt,model);
                predict_accuracy(i) = NaN;
            end

            % Select patches that were classified as object (1)
            objP_nxt = bbox(labels==1,:);

        % If the object was not detected in the previous frame, search in
        % the whole frame (wP)
        else
%             hogS_nxt = hogFeat(I,wP);
            hogS_nxt = hogNSSFeat(I,wP,0,0);            

            if isempty(find(isnan(gtP(i,:)), 1))  
%                 gt_center = [gtP(i,1)+round(gtP(i,3)/2), gtP(i,2)+round(gtP(i,4)/2)];
%                 gtP(i,:) = [gt_center(1)-round(patch_width/2), gt_center(2)-round(patch_height/2), patch_width, patch_height];

                labels_gt = bboxOverlapRatio(gtP(i,:),wP)>=0.7;
                [labels, ~, ~] = svmpredict2(double(labels_gt'),hogS_nxt,model);
                predict_accuracy(i) = length(find(labels(labels_gt)))/length(find(labels_gt));               
            else
                [labels, ~, ~] = svmpredict2(ones(size(wP,1),1),hogS_nxt,model);
                predict_accuracy(i) = NaN;
            end
            objP_nxt = wP(labels==1,:);        
        end

        % If the object was not detected in the current frame but it was
        % found in the previous frame, use MST
        if isempty(objP_nxt) && sum(isnan(objbbox(i-1,:)))==0
            flag(i) = 1;    % MST flag
            T_ = selectPatch(frames(:,:,:,i-1),objbbox(i-1,:));
            x0 = objbbox(i-1,1); y0 = objbbox(i-1,2);
            W1 =objbbox(i-1,3); H = objbbox(i-1,4);

            % Conversion from RGB to Indexed colours
            % to compute the colour probability functions (PDFs)
            if size(frames,3) == 3
                [~,map] = rgb2ind(frames(:,:,:,i-1),65536);
                T = rgb2ind(T_,map);
            else
                [~,map] = gray2ind(frames(:,:,:,i-1),65536);
                T = gray2ind(T_,65536);
            end
            Lmap = length(map) + 1;
            % Estimation of the target PDF
            q = Density_estim(T,Lmap,k,H,W1,0);
            % Flag for target loss
            loss = 0;
            % Similarity evolution along tracking
            f = zeros(1,(Length-1)*max_it);
            % Sum of iterations along tracking and index of f
            f_indx = 1;
            %%%% TRACKING
            for t=i
                % Next frame
                if size(frames,3) == 3
                    I2 = rgb2ind(frames(:,:,:,i),map);
                else
                    I2 = gray2ind(frames(:,:,:,i),65536);
                end
                % Apply the Mean-Shift algorithm to move (x,y)
                % to the target location in the next frame.
                [x,y,loss,f,f_indx] = MeanShift_Tracking(q,I2,Lmap,...
                    Height,width,f_thresh,max_it,x0,y0,H,W1,k,gx,...
                    gy,f,f_indx,loss);
                % Check for target loss. If true, end the tracking
                if loss == 1
                    break;
                else
                y0 = y;
                x0 = x;
                end
            end
            if loss == 0
                objP_nxt = round([x0,y0,W1,H]); % Object detected
            else
                objP_nxt = [NaN,NaN,NaN,NaN];  % Object not detected
            end
        end

        % If the object was detected
        if ((sum(isnan(objP_nxt))==0) & (isempty(objP_nxt)==0))
            % object location estimation
            overlap  = (sum(bboxOverlapRatio(objP_nxt,objP_nxt))-1)';
            objP_nxt_= objP_nxt(overlap>=max(overlap)*0.8,:);
            objbbox(i,:)  = (size(objP_nxt,1)==1)*objP_nxt(1,:) + (1-(size(objP_nxt,1)==1))*round(median(objP_nxt_, 1));

            % Update object model and retrain SVM
            if flag(i) == 0

%                     [hogS] = bgUpdate(I,'mvc',0.05,objbbox(i,:),bgP,bgKeys,hogS);
                    [hogS,bgPVar] = bgUpdate(I,'mvc',0.05,objbbox(i,:),bgP,bgPVar,hogS);

                    I_objP  = selectPatch(I,objbbox(i,:));
                    objCode = briefDescriptor(I_objP,points);
                    if min(pdist2(objCode,binCode,'hamming')) <= bgTsh4 
                        disp(':|')
%                         hogSobj   = hogFeat(I,objbbox(i,:));
                        hogSobj = hogNSSFeat(I,objbbox(i,:),0,1);

                        dist1_add = sqrt(sum((hogSobj - hogSobj_avg).^2,2));
                        if Nobj == Nobj_max
                            hogS(Nobj,:) = hogSobj;
                            objP(Nobj,:) = objbbox(i,:);
                            objFrames(Nobj) = i;
                            binCode(Nobj,:) = objCode;
                            dist1_(Nobj)     = dist1_add;
                        else
                            hogS    = [hogS(1:Nobj,:);hogSobj;hogS(Nobj+1:Nobj+Nbg,:)]; 
                            objP    = [objP;objbbox(i,:)];
                            objFrames = [objFrames;i];
                            binCode   = [binCode;objCode];                            
                            dist1_    = [dist1_;dist1_add];
                            Nobj      = Nobj + 1;
                        end
                        [dist1_,Idist1] = sort(dist1_,'ascend');
                        hogS(1:Nobj,:) = hogS(Idist1,:);
                        binCode = binCode(Idist1,:);
                        objFrames = objFrames(Idist1);
                        objP    = objP(Idist1,:);
                    end
                    hogSobj_avg = mean(hogS(1:Nobj,:));

                    hogSbg_avg  = mean(hogS(Nobj+1:Nobj+Nbg,:));
                    dist2 = pdist2(hogS(Nobj+1:Nobj+Nbg,:),hogSbg_avg);
                    [~,Idist2] = sort(dist2,'ascend');
                    hogS(Nobj+1:Nobj+Nbg,:) = hogS(Idist2+Nobj,:);
%                     bgP = bgP(Idist2,:);
%                     bgPVar = bgPVar(Idist2);

                    % SVM classifier retraining
                    model = svmtrain2([ones(Nobj,1);zeros(Nbg,1)],double(hogS),'-t 0 -c 100');
            end
        else
            objbbox(i,:) = [NaN,NaN,NaN,NaN];  % Object not detected (lost)
        end
        if isempty(find(isnan(objbbox(i,:)),1))
            objboxdraw = objbbox(i,:);
            object_found(i) = 1;
        else
            object_found(i) = 0;
        end
        if objboxdraw(1) < 0
            objboxdraw(3) = objboxdraw(3) + objboxdraw(1) - 1;
            objboxdraw(1) = 1;
        end
        if objboxdraw(2) < 0
            objboxdraw(4) = objboxdraw(4) + objboxdraw(2) - 1;
            objboxdraw(2) = 1;
        end

        % Display frame and object box
        if Display
            title(['Frame ',num2str(i)]);
            if object_found(i)
                imshow(uint8(drawPatches(frames(:,:,:,i),objboxdraw,1)));
            else
                imshow(uint8(frames(:,:,:,i)));
            end
        end
    end

    disp('Calculating performance metrics...')
    % Estimate F-Score    
    [fs,precision,recall,overlap] = fscore(objbbox,gtP);

    % Estimate AOS score
    for thresh = 1:length(AOS_threshold_array)
        AOS_thresh = AOS_threshold_array(thresh);
        [AOS(thresh), false_p(thresh), ROC_accuracy(thresh), ~] = AOS_score(objbbox,gtP,AOS_thresh);
    end

    % Estimate location error
    for thresh = 1:length(location_threshold_array)
        location_thresh = location_threshold_array(thresh);
        location_precision(thresh) = location_error(objbbox,gtP,location_thresh);
    end

    if Display
        close
    end
    disp('Done.')

    % Generate success plots for every level of distortion and the pristine
    % video in one figure
    figure(fig_SP);
    ax_SP = subplot(2,5,test);
    plot(ax_SP,AOS_threshold_array,ROC_accuracy,'k','DisplayName','Pristine');
    title(sprintf('Test %u',test));
%     plot_ax = gca;
%     plot_ax.FontSize = 16;        
    xlabel('Overlap threshold');
    ylabel('Success rate');
    legend('show','Location','southwest');
    %saveas(gcf,strcat('./App_driven_approach/Video_',num2str(v),'_SP_',Distortion),'epsc');
%     close;
    
    % Generate Precision Plots for every level of distortion and the pristine
    % video in one figure
    figure(fig_PP);
    ax_PP = subplot(2,5,test);
    plot(ax_PP,location_threshold_array,location_precision,'k','DisplayName','Pristine');
    title(sprintf('Test %u',test));
%     plot_ax = gca;
%     plot_ax.FontSize = 16;        
    xlabel('Location error threshold');
    ylabel('Precision');
    legend('show','Location','southeast');
%      saveas(gcf,strcat('./Results/Video_',num2str(v),'_PP_',Distortion),'epsc');
%     close;    

%     for o = 1 : length(Q)
%         formatSpec = 'In level %u the portion of frames where MS was used is %d.';
%         str = sprintf(formatSpec,o,sum(flag_lvl(o,:))/numOfFrames)
%     end


    precision_array(:,test) = precision;
    recall_array(:,test) = recall;
    fs_array(:,test) = fs;
    AOS_array(:,test) = mean(AOS);
    loc_err_array(:,test) = location_precision;

    %         Para generar tests
            fsMVCnw        = fs_array(:,test);
            precisionMVCnw = precision_array(:,test);
            recallMVCnw    = recall_array(:,test);
            save(strcat(bboxName,'Test',num2str(test)),...
                'fsMVCnw','precisionMVCnw','recallMVCnw','-append');
end
toc
fig_SP.Visible = 'on';
fig_PP.Visible = 'on';
csvwrite(strcat('Video',num2str(v),'Tests.csv'),[precision_array',recall_array',fs_array',AOS_array']);