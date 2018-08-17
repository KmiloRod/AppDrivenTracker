function Test_ROC_AOS_MVC_train(Distortion,v,Display,varargin)
% Generates success and precision plots from the tracker performance on
% the video number v affected by three levels of the distortion of image
% quality specified by the string Distortion ('pristine', 'MPEG4',
% 'Gaussian', 'S & P' or 'Blur'). The object and background patches are
% represented only by HOG features. The boolean parameter Display specifies
% if each frame is shown during execution with the tracked object bounding
% box added during execution. A filename can be added as an input after
% Display, to generate an AVI video file with the resultant video annotated
% with the tracked object bounding boxes.
% This function is used to generate samples for training a classifier for
% the app-driven quality enhancement of the tracker. Therefore, along with
% the results metrics, the function saves a cell array with a matrix per
% frame with patch samples as rows, and location, size and
% suitable/non-suitable labels as columns.

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
    
% global BlockSize BlockOverlap CellSize Numbins

% List of tests numbers that yielded the best F-score for each video
% (different background distributions)
tests_array = [2, 1, 5, 8, 5, 4, 4, 6, 1, 9, 8, 8, 7, 1, 8, 7, 10, 10, 9, 9, 10, 4, 5, 2, 6, 4, 4, 3, 4, 10];
% videos_array = [1, 2, 4, 5, 6, 7, 8];

% Array of AOS threshold values for generating success plots
AOS_threshold_array = linspace(0,1,100);
location_threshold_array = linspace(0,50,100);

% for vid_index = 1:length(videos_array)
%     
%     v = videos_array(vid_index);

    % Selected test for the specified video v
    test = tests_array(v);

    tic

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
            %Q = [0.00003 0.00005 0.0001];
        otherwise
            Q = 0;
    end

    % Loading video file and parameters
    load(vidName{v},'frames');
    frames_pristine = frames;
    numOfFrames = size(frames,4);
    Height = size(frames,1);
    width = size(frames,2);
    imSize = [Height,width];
    
    ovrlp = 1/4; %[1/2 1/3 1/4 1/5];
    predict_accuracy = zeros(length(Q),numOfFrames);
    total_object_found = zeros(length(Q),numOfFrames);
    flag_lvl = zeros(length(Q),numOfFrames);

    % Load pristine results for comparison with distortions
    if ~strcmp(Distortion,'pristine')
        load(strcat('./Results/MVC_Results_Video_',num2str(v),'_pristine'));
        % AOS_pristine = AOS;
        ROC_accuracy_pristine = ROC_accuracy;
        location_precision_pristine = location_precision;
        % false_p_pristine = false_p;
    end

    %training_samples = cell(length(Q), numOfFrames);
    training_samples_obj = cell(length(Q), numOfFrames);
    training_samples_bg = cell(length(Q), numOfFrames);

    % Test for each level of distortion
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

        % Load ground-truth of the video
        load(strcat(vidName{v},'_gt'),'gtP');

        % Name of the file with the initial object bounding box
        bboxName = strcat('bbox_',vidName{v});
        % If no initial bounding box, the user has to select it manually
        if ~exist(strcat(bboxName,'.mat'),'file')
            figure;
            imshow(uint8(frames(:,:,:,1)),'InitialMagnification',150);
            h     = msgbox('Select the object-square region by clicking and dragging','Object Square','modal');
            objbbox = floor(getrect);
            save(bboxName,'objbbox');
        else
            load(bboxName,'objbbox');
        end

        % Load variables for the video (object and background boxes, etc.)
        load(strcat(bboxName,'Test',num2str(test)),...                  % Randomly distributed background patches
           'objP','bgP','objbbox','context','bgKeys',...
           'binCode','points','bgTsh4',...
           'CellSize','BlockSize','BlockOverlap','Numbins','N_HOG');
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
        [labels, accuracy_L, ~] = svmpredict2([ones(Nobj,1);zeros(Nbg,1)],hogS,model);
        predict_accuracy(o,1) = accuracy_L(1)/100;
        
        % Neighbouring window for object search
        D = searchWindow(objbbox);

        flag = zeros(1,size(frames,4));     % MST flag
        objbbox = zeros(size(frames,4),4);
        objbbox(1,:) = objP(1,:);
        Length = size(frames,4);

        patch_width = objbbox(1,3); patch_height = objbbox(1,4);        
        
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

                % HOG features of the window boxes
                hogS_nxt   = hogNSSFeat(I,bbox,0,0);
                
                % If there is ground-truth for the current frame
                if isempty(find(isnan(gtP(i,:)), 1))

                    % HOG features of the background patches in the current frame
                    bg_nonOvlp_ind = bboxOverlapRatio(bgP,gtP(i,:))==0;
                    hogS_bG = hogNSSFeat(I,bgP(bg_nonOvlp_ind,:),0,0);
                    
                    % Label as matches the window patches with overlap greater
                    % than 0.9 with the ground-truth for accuracy estimation
                    labels_gt = bboxOverlapRatio(gtP(i,:),bbox,'Min')>=0.9;
                    %labels_gt = bboxOverlapRatio(gtP(i,:),bbox)>=0.7;
                    
                    % SVM classifier prediction
                    [labels, ~, ~] = svmpredict2(double(labels_gt'),hogS_nxt,model);
                    [labels_bG, ~, ~] = svmpredict2(zeros(size(hogS_bG,1),1),hogS_bG,model);
                    predict_accuracy(o,i) = length(find(labels(labels_gt)))/length(find(labels_gt));
                    
                    % Identify patches correctly classified
                    %suitable = [~xor(labels_gt, labels')'; ~labels_bG];
                    suitable_obj = labels(labels_gt);
                    suitable_bg = [labels(~labels_gt); ~labels_bG];
%                     suitable = ~xor(labels_gt, labels')';
                    %training_samples{o,i} = [[bbox; bgP(bg_nonOvlp_ind,:)], suitable];
                    training_samples_obj{o,i} = [bbox(labels_gt,:), suitable_obj];
                    training_samples_bg{o,i} = [[bbox(~labels_gt,:); bgP(bg_nonOvlp_ind,:)], suitable_bg];
%                     training_samples{o,i} = [bbox, suitable];

                % If there is no ground-truth for the current frame, does not
                % calculate prediction accuracy
                else        
                    % HOG features of the background patches in the current frame
                    bg_nonOvlp_ind = 1:size(bgP,1);
                    hogS_bG = hogNSSFeat(I,bgP(bg_nonOvlp_ind,:),0,0);
                    
                    % SVM classifier prediction
                    [labels, ~, ~] = svmpredict2(zeros(size(bbox,1),1),hogS_nxt,model);
                    [labels_bG, ~, ~] = svmpredict2(zeros(size(hogS_bG,1),1),hogS_bG,model);
                    
                    % Identify patches correctly classified
                    %suitable = ~labels_bG;
                    suitable_bg = ~labels_bG;
                    %training_samples{o,i} = [bgP, suitable];
                    training_samples_bg{o,i} = [bgP, suitable_bg];
                                        
                    predict_accuracy(o,i) = NaN;            
                end

                % Select patches that were classified as object (1)
                objP_nxt = bbox(labels==1,:);

            % If the object was not detected in the previous frame, search in
            % the whole frame (wP)
            else
                hogS_nxt = hogNSSFeat(I,wP,0,0);  

                if isempty(find(isnan(gtP(i,:)), 1))  

                    labels_gt = bboxOverlapRatio(gtP(i,:),wP,'Min')>=0.9;
                    %labels_gt = bboxOverlapRatio(gtP(i,:),wP)>=0.7;
                    [labels, ~, ~] = svmpredict2(double(labels_gt'),hogS_nxt,model);
%                     [labels_bG, ~, ~] = svmpredict2(zeros(size(hogS_bG,1),1),hogS_bG,model);
                    predict_accuracy(o,i) = length(find(labels(labels_gt)))/length(find(labels_gt));               

                    % Identify patches correctly classified
                    %suitable = ~xor(labels_gt, labels');
                    suitable_obj = labels(labels_gt);
                    suitable_bg = labels(~labels_gt);
                    %training_samples{o,i} = [wP, suitable'];
                    training_samples_obj{o,i} = [wP(labels_gt,:), suitable_obj];
                    training_samples_bg{o,i} = [wP(~labels_gt,:), suitable_bg];
                else
                    % HOG features of the background patches in the current frame
                    bg_nonOvlp_ind = 1:size(bgP,1);
                    hogS_bG = hogNSSFeat(I,bgP(bg_nonOvlp_ind,:),0,0);
                    
                    % SVM classifier prediction
                    [labels, ~, ~] = svmpredict2(zeros(size(wP,1),1),hogS_nxt,model);
                    [labels_bG, ~, ~] = svmpredict2(zeros(size(hogS_bG,1),1),hogS_bG,model);
                    
                    % Identify patches correctly classified
                    %suitable = ~labels_bG;
                    suitable_bg = ~labels_bG;
                    %training_samples{o,i} = [bgP, suitable];
                    training_samples_bg{o,i} = [bgP, suitable_bg];
                    
                    predict_accuracy(o,i) = NaN;              
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
                
                % Classification of background patches for quality training labeling
%                 [labels_bG, ~, ~] = svmpredict2(zeros(size(hogS_bG,1),1),hogS_bG,model);
                
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
                    
                    % Identify if the target patch was correctly detected
%                     if isempty(find(isnan(gtP(i,:)), 1))
%                         
%                         labels_gt = bboxOverlapRatio(gtP(i,:),objP_nxt,'Min')>=0.9;                        
%                         
%                         % HOG features of the object and background patches in the current frame
%                         bg_nonOvlp_ind = bboxOverlapRatio(bgP,gtP(i,:))==0;
%                         hogS_all = hogNSSFeat(I,[objP_nxt; bgP(bg_nonOvlp_ind,:)],0,0);
% 
%                         % SVM classifier prediction (for training)
%                         [labels, ~, ~] = svmpredict2([1; zeros(size(hogS_bG,1),1)],hogS_all,model);
% 
%                         suitable = [~xor(labels_gt, labels(1)')'; ~labels(2:end)];
%                         training_samples{o,i} = [[objP_nxt; bgP(bg_nonOvlp_ind,:)], suitable];
%                     end
                else
                    objP_nxt = [NaN,NaN,NaN,NaN];  % Object not detected
                end
            end

            % If the object was detected
            if ((sum(isnan(objP_nxt))==0) & (isempty(objP_nxt)==0))
                % object location estimation
                %overlap  = (sum(bboxOverlapRatio(objP_nxt,objP_nxt,'Min'))-1)';
                overlap  = (sum(bboxOverlapRatio(objP_nxt,objP_nxt))-1)';
                objP_nxt_= objP_nxt(overlap>=max(overlap)*0.8,:);
                objbbox(i,:)  = (size(objP_nxt,1)==1)*objP_nxt(1,:) + (1-(size(objP_nxt,1)==1))*round(median(objP_nxt_,1));

                % Update object model and retrain SVM
                if flag(i) == 0

                        [hogS,bgPVar] = bgUpdate(I,'mvc',0.05,objbbox(i,:),bgP,bgPVar,hogS);

                        I_objP  = selectPatch(I,objbbox(i,:));
                        objCode = briefDescriptor(I_objP,points);
                        if min(pdist2(objCode,binCode,'hamming')) <= bgTsh4 
                            disp(':|')
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
        [fs(o),precision(o),recall(o),overlap] = fscore(objbbox,gtP);
        total_object_found(o,:) = object_found;
        final_objbbox{o,:} = objbbox;
        flag_lvl(o,:) = flag;

        % Estimate AOS (Average Overlap Score)
        for thresh = 1:length(AOS_threshold_array)
            AOS_thresh = AOS_threshold_array(thresh);
            [AOS(o,thresh), false_p(o,thresh), ROC_accuracy(o,thresh), ~] = AOS_score(objbbox,gtP,AOS_thresh);
        end
        
        % Estimate location error average
        for thresh = 1:length(location_threshold_array)
            location_thresh = location_threshold_array(thresh);
            location_precision(o,thresh) = location_error(objbbox,gtP,location_thresh);
        end
        
        if Display
            close
        end
        disp('Done.')
        
        % If a video file name was specified, generate the resultant AVI
        % files with the video annotated with the tracked object bounding
        % box for each distortion level
        if nargin>3
            generateBboxVideoMP4(strcat(varargin{1},'_',num2str(o)),frames,objbbox,100,24) 
        end
    end

    toc

    % Generate Success Plots for every level of distortion and the pristine
    % video in one figure
    color_array = 'brgmck';

    figure;
    if ~strcmp(Distortion,'pristine')
        plot(AOS_threshold_array,ROC_accuracy_pristine(1,:),'k','DisplayName','Pristine');
        hold on
        for o = 1:length(Q)
            plot(AOS_threshold_array,ROC_accuracy(o,:),color_array(o),'DisplayName',num2str(o));
        end
        hold off
        title(sprintf('Success plot, Video %u, %s distortion',v,Distortion));    
    else
        plot(AOS_threshold_array,ROC_accuracy(1,:),'k','DisplayName','Pristine');
        title(sprintf('Success plot, Video %u pristine',v));
    end    
    plot_ax = gca;
    plot_ax.FontSize = 16;        
    xlabel('Overlap threshold');
    ylabel('Success rate');
    legend('show','Location','southwest');
    %saveas(gcf,strcat('./Results/Video_',num2str(v),'_SP_',Distortion),'epsc');
%      close;

    % Generate Precision Plots for every level of distortion and the pristine
    % video in one figure
    color_array = 'brgmck';

    figure;
    if ~strcmp(Distortion,'pristine')
        plot(location_threshold_array,location_precision_pristine(1,:),'k','DisplayName','Pristine');
        hold on
        for o = 1:length(Q)
            plot(location_threshold_array,location_precision(o,:),color_array(o),'DisplayName',num2str(o));
        end
        hold off
        title(sprintf('Precision plot, Video %u, %s distortion',v,Distortion));    
    else
        plot(location_threshold_array,location_precision(1,:),'k','DisplayName','Pristine');
        title(sprintf('Precision plot, Video %u pristine',v));
    end    
    plot_ax = gca;
    plot_ax.FontSize = 16;        
    xlabel('Location error threshold');
    ylabel('Precision');
    legend('show','Location','southeast');
    %saveas(gcf,strcat('./Results/Video_',num2str(v),'_PP_',Distortion),'epsc');
%      close;

    % Save tests results
    if strcmp(Distortion,'S & P')
         %save(strcat('./Results/MVC_Results_Video_',num2str(v),'_S_P'),'predict_accuracy','AOS','ROC_accuracy','false_p','fs','total_object_found','location_precision','flag_lvl','final_objbbox','training_samples');
         save(strcat('./Results/MVC_Results_Video_objBg_',num2str(v),'_S_P'),'predict_accuracy','AOS','ROC_accuracy','false_p','fs','total_object_found','location_precision','flag_lvl','final_objbbox','training_samples_obj','training_samples_bg');
    else
         %save(strcat('./Results/MVC_Results_Video_',num2str(v),'_',Distortion),'predict_accuracy','AOS','ROC_accuracy','false_p','fs','total_object_found','location_precision','flag_lvl','final_objbbox','training_samples');
         save(strcat('./Results/MVC_Results_Video_objBg_',num2str(v),'_',Distortion),'predict_accuracy','AOS','ROC_accuracy','false_p','fs','total_object_found','location_precision','flag_lvl','final_objbbox','training_samples_obj','training_samples_bg');
         
    end

    for o = 1 : length(Q)
        formatSpec = 'In level %u the portion of frames where MS was used is %2.2f.';
        str = sprintf(formatSpec,o,sum(flag_lvl(o,:))/numOfFrames)
    end