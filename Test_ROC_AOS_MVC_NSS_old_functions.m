function Test_ROC_AOS_MVC_NSS_old_functions(Distortion,v,NSS,Cs,Display)
% Generates success plots from the tracker performance on the video number
% v affected by three levels of the distortion of image quality specified
% by the string Distortion ('pristine', 'MPEG4', 'Gaussian', 'S & P' or
% 'Blur'). NSS = 1 includes NSS features in the SVM training; NSS = 0 uses
% only HOG features. The parameter Cs is the scaling factor for the NSS
% features (Cs = 1 denotes no scaling).

path(path,'./05_pedestrian3')
path(path,'./04_pedestrian2')
path(path,'./03_pedestrian1')
path(path,'./06_car')
path(path,'./02_jumping')
path(path,'./functions2')
path(path,'./MeanShift_Code')
path(path,'./bbox_configs')
path(path,'./matlab')
path(path,'./videos')

% List of used videos
vidName = {'car','jumping','pedestrian1','pedestrian2','pedestrian3','charger','cameraJuan','gurgaon'};

% Names of ground-truth files for each video
gtName  = {'car_gt','jumping_gt','pedestrian1_gt','pedestrian2_gt','pedestrian3_gt','charger_gt','cameraJuan_gt','gurgaon_gt'};
% global BlockSize BlockOverlap CellSize Numbins

% List of tests numbers that yielded the best F-score for each video
% (different background distributions)
tests_array = [1, 3, 1, 2, 2, 3, 5, 3];
% Array of AOS threshold values for generating success plots
AOS_threshold_array = linspace(0.1,1,19);

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
    otherwise
        Q = 0;
end


ovrlp = 1/4; %[1/2 1/3 1/4 1/5];

% Load pristine results for comparison with distortions
if ~strcmp(Distortion,'pristine')
    if NSS
        load(strcat('Prueba_AOS_NSS_Video_',num2str(v),'_pristine_Cs',num2str(Cs)));
    else
        load(strcat('Prueba_AOS_HOG_Video_',num2str(v),'_pristine_Cs',num2str(Cs)));
    end
    % AOS_pristine = AOS;
    ROC_accuracy_pristine = ROC_accuracy;
    % false_p_pristine = false_p;
end

% Test for each level of distortion
for o = 1 : length(Q) 
    load(vidName{v},'frames');
            
    % Only consider first 100 frames of the video
    frames = frames(:,:,:,1:100);
    
    % Generate distorted version of the video
    switch Distortion
        case 'MPEG4'
            [frames] = vidnoise(frames,'MPEG-4',Q(o));
            frames = uint8(frames);
        case 'Gaussian'
            [frames] = vidnoise(uint8(frames),'gaussian',[0, Q(o)]);
            frames = uint8(frames);
        case 'Blur'
            [frames] = vidnoise(uint8(frames),'blur',Q(o));
            frames = uint8(frames);
        case 'S & P'
            [frames] = vidnoise(uint8(frames),'salt & pepper',Q(o));
            frames = uint8(frames);
    end
    
    % Load ground-truth of the video
    load(gtName{v},'gtP');
    
    % Video parameters
    numOfFrames = size(frames,4);
    Height = size(frames,1);
    width = size(frames,2);
    imSize = [Height,width];

    % Name of the file with the initial object bounding box
    bboxName = strcat('bbox_',vidName{v});
    % If no initial bounding box, the user has to select it manually
    if ~exist(strcat(bboxName,'.mat'),'file')
        imshow(uint8(frames(:,:,:,1)),'InitialMagnification',150);
        h     = msgbox('Select the object-square region by clicking and dragging','Object Square','modal');
        objbbox = floor(getrect);
        save(bboxName,'objbbox');
    else
        load(bboxName,'objbbox');
    end
    
    % Load variables for the video (object and background boxes, etc.)
    load(strcat(bboxName,'Test',num2str(test)),...
       'objP','bgP','objbbox','context','bgKeys',...
       'binCode','points','bgTsh4',...
       'CellSize','BlockSize','BlockOverlap','Numbins','N_HOG');
    Nbg  = size(bgP,1);     % Number of background patches
    Nobj = size(objP,1);    % Number of object patches
    Nobj_max = N_HOG - Nbg; % Maximum number of possible object patches


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

    I = double(rgb2gray(uint8(frames(:,:,:,1))));
    % bgPVar_init = patchVariance(I,bgP);
    
    % Initial sliding window patches
    wP = slidingWindow(1,1,imSize(2),imSize(1),objbbox(3),objbbox(4),ovrlp);
    objFrames = ones(Nobj,1);
    
    % Display the video frames during processing
    if Display
        figure; imshow(uint8(drawPatches(frames(:,:,:,1),objbbox(1,:),1)));
    end
    objboxdraw = objbbox(1,:);
    
    % Extraction of HOG and NSS features from all the patches
%     hogS   = hogFeat(I,[objP;bgP]);
    hogS   = hogNSSFeat(I,[objP;bgP],0,Cs);

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
    bgKeys = bgKeys(Idist2);

    % Sort and concatenate NSS features
    if NSS                    
        nssS   = nssFeat(I,[objP;bgP]) / Cs;
        nssS(1:Nobj,:) = nssS(Idist1,:);
        nssS(Nobj+1:Nobj+Nbg,:) = nssS(Idist2+Nobj,:);
        featuresS = [hogS, nssS];  % Concatenation of NSS features to HOG features
    else
        featuresS = hogS;  % Only HOG features
    end

    % Training of SVM classifier
    model = svmtrain2([ones(Nobj,1);zeros(Nbg,1)],double(featuresS),'-t 0 -c 100');
    % Accuracy of SVM classifier prediction
    [~, accuracy_L, ~] = svmpredict2([ones(Nobj,1);zeros(Nbg,1)],featuresS,model);
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
        I = double(rgb2gray(uint8(frames(:,:,:,i))));

        % If the object was detected in the previous frame, search in the
        % neighbouring window
        if sum(isnan(objbbox(i-1,:)))==0
            bbox = ones(size(D,1),1)*objbbox(i-1,:) + D; % posible bboxes where the object is located in frame t + 1
            % Remove boxes outside the frame
            bbox(bbox(:,1)<1 | bbox(:,2)<1 | (bbox(:,1)+bbox(:,3)-1)>width | (bbox(:,2)+bbox(:,4)-1)>Height,:)=[];

%             hogS_nxt = hogFeat(I,bbox); % HOG features of the window boxes

            % HOG and NSSfeatures of the window boxes
            hogS_nxt = hogNSSFeat(I,bbox,0,Cs);
            if NSS
                nssS_nxt = nssFeat(I,bbox) / Cs;
                features_nxt = [hogS_nxt, nssS_nxt];
            else
                features_nxt = hogS_nxt;
            end      
            
            
            % If there is ground-truth for the current frame
            if isempty(find(isnan(gtP(i,:)), 1))
                % Adjust size of ground-truth patch to match object patches
                gt_center = [gtP(i,1)+round(gtP(i,3)/2), gtP(i,2)+round(gtP(i,4)/2)];
                gtP(i,:) = [gt_center(1)-round(patch_width/2), gt_center(2)-round(patch_height/2), patch_width, patch_height];
                
                % Label as matches the window patches with overlap greater
                % than 0.7 with the ground-truth for accuracy estimation
                labels_gt = bboxOverlapRatio(gtP(i,:),bbox)>=0.7;
                
                % SVM classifier prediction
                [labels, ~, ~] = svmpredict2(double(labels_gt'),features_nxt,model);
                predict_accuracy(o,i) = length(find(labels(labels_gt)))/length(find(labels_gt));
                
            % If there is no ground-truth for the current frame, does not
            % calculate prediction accuracy
            else
                [labels, ~, ~] = svmpredict2(ones(size(bbox,1),1),features_nxt,model);
                predict_accuracy(o,i) = NaN;
            end
            
            % Select patches that were classified as object (1)
            objP_nxt = bbox(labels==1,:);
            
        % If the object was not detected in the previous frame, search in
        % the whole frame (wP)
        else
%             hogS_nxt = hogFeat(I,wP);
            hogS_nxt = hogNSSFeat(I,wP,0,Cs);
            if NSS
                nssS_nxt = nssFeat(I,wP) / Cs;
                features_nxt = [hogS_nxt, nssS_nxt];
            else
                features_nxt = hogS_nxt;
            end    
            
            if isempty(find(isnan(gtP(i,:)), 1))  
                gt_center = [gtP(i,1)+round(gtP(i,3)/2), gtP(i,2)+round(gtP(i,4)/2)];
                gtP(i,:) = [gt_center(1)-patch_width, gt_center(2)-patch_height, patch_width, patch_height];                    

                labels_gt = bboxOverlapRatio(gtP(i,:),wP)>=0.7;
                [labels, ~, ~] = svmpredict2(double(labels_gt'),features_nxt,model);
                predict_accuracy(o,i) = length(find(labels(labels_gt)))/length(find(labels_gt));               
            else
                [labels, ~, ~] = svmpredict2(ones(size(wP,1),1),features_nxt,model);
                predict_accuracy(o,i) = NaN;
            end
            objP_nxt = wP(labels==1,:);        
        end

        % If the object was not detected in the current frame but it was
        % found in the previous frame, use MST
        if isempty(objP_nxt) && sum(isnan(objbbox(i-1,:)))==0
            flag(i) = 1;    % MST flag
            T_ = selectPatch(frames(:,:,:,i-1),objbbox(i-1,:));
            x0=objbbox(i-1,1); y0= objbbox(i-1,2);
            W1 =objbbox(i-1,3); H = objbbox(i-1,4);
            
            % Conversion from RGB to Indexed colours
            % to compute the colour probability functions (PDFs)
            [I1,map] = rgb2ind(frames(:,:,:,i-1),65536);
            Lmap = length(map)+1; T = rgb2ind(T_,map);
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
                I2 = rgb2ind(frames(:,:,:,i),map);
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
            objbbox(i,:)  = (size(objP_nxt,1)==1)*objP_nxt(1,:) + (1-(size(objP_nxt,1)==1))*round(median(objP_nxt_));

            % Update object model and retrain SVM
            if flag(i) == 0

                    if NSS
                        [hogS,~,nssS] = bgUpdateNSS_oldfunctions(I,'mvc',0.05,objbbox(i,:),bgP,bgKeys,hogS,nssS,Cs);
                    else
                        [hogS] = bgUpdate(I,'mvc',0.05,objbbox(i,:),bgP,bgKeys,hogS);
                    end

                    I_objP  = selectPatch(I,objbbox(i,:));
                    objCode = briefDescriptor(I_objP,points);
                    if min(pdist2(objCode,binCode,'hamming')) <= bgTsh4 
                        disp(':|')
%                         hogSobj   = hogFeat(I,objbbox(i,:));
                        hogSobj   = hogNSSFeat(I,objbbox(i,:),0,Cs);
                        
                        dist1_add = sqrt(sum((hogSobj - hogSobj_avg).^2,2));
                        if Nobj == Nobj_max
                            hogS(Nobj,:) = hogSobj;
                            objP(Nobj,:) = objbbox(i,:);
                            objFrames(Nobj) = i;
                            binCode(Nobj,:) = objCode;
                            dist1(Nobj)     = dist1_add;
                            if NSS
                                nssSobj   = nssFeat(I,objbbox(i,:)) / Cs;                                
                                nssS(Nobj,:) = nssSobj;
                            end
                        else
                            hogS    = [hogS(1:Nobj,:);hogSobj;hogS(Nobj+1:Nobj+Nbg,:)]; 
                            objP    = [objP;objbbox(i,:)];
                            objFrames = [objFrames;i];
                            binCode   = [binCode;objCode];                            
                            dist1     = [dist1_;dist1_add];
                            if NSS
                                nssSobj   = nssFeat(I,objbbox(i,:)) / Cs;                                
                                nssS    = [nssS(1:Nobj,:);nssSobj;nssS(Nobj+1:Nobj+Nbg,:)]; 
                            end
                            Nobj      = Nobj + 1;
                        end
                    end
                    [dist1_,Idist1] = sort(dist1,'ascend');
                    hogS(1:Nobj,:) = hogS(Idist1,:);
                    binCode = binCode(Idist1,:);
                    objFrames = objFrames(Idist1);
                    objP    = objP(Idist1,:);
                    hogS(Nobj+1:Nobj+Nbg,:) = hogS(Idist2+Nobj,:);           
                    hogSobj_avg = mean(hogS(1:Nobj,:));
                    hogSbg_avg  = mean(hogS(Nobj+1:Nobj+Nbg,:));

                    if NSS
                        nssS(1:Nobj,:) = nssS(Idist1,:);
                        nssS(Nobj+1:Nobj+Nbg,:) = nssS(Idist2+Nobj,:);            
                        featuresS = [hogS, nssS];  % Concatenation of NSS features to HOG features
                    else
                        featuresS = hogS;  % Only HOG features
                    end

                    model = svmtrain2([ones(Nobj,1);zeros(Nbg,1)],double(featuresS),'-t 0 -c 100');
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
    [fs(o),precision(o),recall(o),overlap] = fscore(objbbox,gtP);
    total_object_found(o,:) = object_found;
    flag_lvl(o,:) = flag;

    % Estimate AOS score
    for thresh = 1:length(AOS_threshold_array)
        AOS_thresh = AOS_threshold_array(thresh);
        [AOS(o,thresh), false_p(o,thresh), ROC_accuracy(o,thresh), ~] = AOS_score(objbbox,gtP,AOS_thresh);
    end
    if Display
        close
    end
end

toc

% Generate success plots for every level of distortion and the pristine
% video in one figure

color_array = 'brmgck';

figure;
if ~strcmp(Distortion,'pristine')
%    plot(false_p_pristine(1,:),ROC_accuracy_pristine(1,:),'k','DisplayName','Pristine');
    plot(AOS_threshold_array,ROC_accuracy_pristine(1,:),'k','DisplayName','Pristine');
    hold on
    for o = 1:length(Q)
        %plot(false_p(o,:),ROC_accuracy(o,:),color_array(o),'DisplayName',num2str(o));
        plot(AOS_threshold_array,ROC_accuracy(o,:),color_array(o),'DisplayName',num2str(o));
    end
    hold off
    if NSS
        title(sprintf('Video %u, %s distortion with NSS',v,Distortion));    
    else
        title(sprintf('Video %u, %s distortion only HOG',v,Distortion));    
    end
else
    %plot(false_p(1,:),ROC_accuracy(1,:),'k','DisplayName','Pristine');
    plot(AOS_threshold_array,ROC_accuracy(1,:),'k','DisplayName','Pristine');
    if NSS
        title(sprintf('Video %u pristine with NSS',v));
    else
        title(sprintf('Video %u pristine only HOG',v));
    end
end    
plot_ax = gca;
plot_ax.FontSize = 16;        
xlabel('Overlap threshold');
ylabel('Success rate');
legend('show','Location','southwest');
%saveas(gcf,strcat('./SVM_new_results/Video_',num2str(v),'_SP_',Distortion),'epsc');
%close;

% Save tests results
if NSS
    if strcmp(Distortion,'S & P')
        save(strcat('AOS_NSS_Video_',num2str(v),'_S_P_Cs',num2str(Cs)),'predict_accuracy','AOS','ROC_accuracy','false_p','fs','total_object_found','flag_lvl');
    else
        save(strcat('AOS_NSS_Video_',num2str(v),'_',Distortion,'_Cs',num2str(Cs)),'predict_accuracy','AOS','ROC_accuracy','false_p','fs','total_object_found','flag_lvl');
    end
else
    if strcmp(Distortion,'S & P')
        save(strcat('AOS_HOG_Video_',num2str(v),'_S_P'),'predict_accuracy','AOS','ROC_accuracy','false_p','fs','total_object_found','flag_lvl');
    else
        save(strcat('AOS_HOG_Video_',num2str(v),'_',Distortion),'predict_accuracy','AOS','ROC_accuracy','false_p','fs','total_object_found','flag_lvl');
    end
end

for o = 1 : length(Q)
    formatSpec = 'In level %u the portion of frames where MS was used is %d.';
    str = sprintf(formatSpec,o,sum(flag_lvl(o,:))/numOfFrames)
end
