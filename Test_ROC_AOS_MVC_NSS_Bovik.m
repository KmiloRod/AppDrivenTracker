function Test_ROC_AOS_MVC_NSS_Bovik(v,Cs)
% Generates success plots from the tracker performance on the video number
% v affected by three levels of four common image quality distortions
% ('pristine', 'MPEG4', 'Gaussian', 'S & P' and 'Blur'). The algorithm uses
% the NIQE image quality metric  to determine if NSS features are added as
% inputs to the SVM. It compares the NIQE from each frame with a threshold;
% it it's above the thresholde, NSS features are added to the HOG features
% used by default. This function evaluates the performance of the system
% for several values of the NIQE threshold. The input parameter Cs is the
% scaling factor for the NSS features (Cs = 1 denotes no scaling).


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


vidName = {'car','jumping','pedestrian1','pedestrian2','pedestrian3','charger','cameraJuan','gurgaon'};
gtName  = {'car_gt','jumping_gt','pedestrian1_gt','pedestrian2_gt','pedestrian3_gt','charger_gt','cameraJuan_gt','gurgaon_gt'};
global BlockSize BlockOverlap CellSize Numbins

tests_array = [1, 3, 1, 2, 2, 3, 5, 3];
AOS_threshold_array = linspace(0.1,1,19);

% NIQE parameters
NIQE_threshold_array = linspace(4,30,10);
%NIQE_threshold_array = [5,6];
load modelparameters.mat
 
blocksizerow    = 96;
blocksizecol    = 96;
blockrowoverlap = 0;
blockcoloverlap = 0;

Distortion = {'pristine','MPEG4','Gaussian','Blur','S & P'};
%Distortion = {'pristine','MPEG4'};
test = tests_array(v);
%NumOfFrames = 100;

tic

ovrlp = 1/4;%[1/2 1/3 1/4 1/5];

for o = 1 : length(Distortion)
    load(vidName{v},'frames');
    switch Distortion{o}
        case 'MPEG4'
            Q = 0;
            %[frames] = vidnoise(frames(:,:,:,1:NumOfFrames),'MPEG-4',Q);
            [frames] = vidnoise(frames,'MPEG-4',Q);
            frames = uint8(frames);
        case 'Gaussian'
            Q = 0.1;
            %[frames] = vidnoise(uint8(frames(:,:,:,1:NumOfFrames)),'gaussian',[0, Q]);
            [frames] = vidnoise(uint8(frames),'gaussian',[0, Q]);
            frames = uint8(frames);
        case 'Blur'
            Q = 15;
            %[frames] = vidnoise(uint8(frames(:,:,:,1:NumOfFrames)),'blur',Q);
            [frames] = vidnoise(uint8(frames),'blur',Q);
            frames = uint8(frames);
        case 'S & P'
            Q = 0.1;
            %[frames] = vidnoise(uint8(frames(:,:,:,1:NumOfFrames)),'salt & pepper',Q);
            [frames] = vidnoise(uint8(frames),'salt & pepper',Q);
            frames = uint8(frames);
        otherwise
            Q = 0;
            %frames = frames(:,:,:,1:NumOfFrames);
    end
    for thr = 1:length(NIQE_threshold_array)        
        load(gtName{v},'gtP');
        numOfFrames = size(frames,4);
        Height = size(frames,1);
        width = size(frames,2);
        imSize = [Height,width];

        bboxName = strcat('bbox_',vidName{v});

        if ~exist(strcat(bboxName,'.mat'),'file')
            imshow(uint8(frames(:,:,:,1)),'InitialMagnification',150);
            h     = msgbox('Select the object-square region by clicking and dragging','Object Square','modal');
            objbbox = floor(getrect);
            save(bboxName,'objbbox');
        else
            load(bboxName,'objbbox');
        end

        load(strcat(bboxName,'Test',num2str(test)),...
           'objP','bgP','objbbox','context','bgKeys',...
           'binCode','points','bgTsh4',...
           'CellSize','BlockSize','BlockOverlap','Numbins','N_HOG');
        Nbg  = size(bgP,1);
        Nobj = size(objP,1);
        Nobj_max = N_HOG - Nbg;

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
        bgPVar_init = patchVariance(I,bgP);    
        wP = slidingWindow(1,1,imSize(2),imSize(1),objbbox(3),objbbox(4),ovrlp);
        objFrames = ones(Nobj,1);

%        figure; imshow(uint8(drawPatches(frames(:,:,:,1),objbbox(1,:),1)));
        objboxdraw = objbbox(1,:);

        hogS   = hogFeat(I,[objP;bgP]);
    %        hogWS  = hogFeat(I,wP);

        hogSobj_avg = mean(hogS(1:Nobj,:));
        hogSbg_avg  = mean(hogS(Nobj+1:Nobj+Nbg,:));
        dist1 = pdist2(hogS(1:Nobj,:),hogSobj_avg);
        dist2 = pdist2(hogS(Nobj+1:Nobj+Nbg,:),hogSbg_avg);
        [dist1_,Idist1] = sort(dist1,'ascend');
        [~,Idist2] = sort(dist2,'ascend');

        hogS(1:Nobj,:) = hogS(Idist1,:);
        hogS(Nobj+1:Nobj+Nbg,:) = hogS(Idist2+Nobj,:);
        bgKeys = bgKeys(Idist2);

        % NIQE calculation and NSS use decision
        quality = computequality(I,blocksizerow,blocksizecol,blockrowoverlap,blockcoloverlap,mu_prisparam,cov_prisparam);
        NSS = quality >= NIQE_threshold_array(thr);

        nssS   = nssFeat(I,[objP;bgP]) / Cs;            
        nssS(1:Nobj,:) = nssS(Idist1,:);
        nssS(Nobj+1:Nobj+Nbg,:) = nssS(Idist2+Nobj,:);

        if NSS
            featuresS = [hogS, nssS];  % Concatenation of NSS features to HOG features
        else
            featuresS = hogS;  % Only HOG features
        end

        total_NIQE(o,1) = quality;
        
        model = svmtrain2([ones(Nobj,1);zeros(Nbg,1)],double(featuresS),'-t 0 -c 100');
        [~, accuracy_L, ~] = svmpredict2([ones(Nobj,1);zeros(Nbg,1)],featuresS,model);
    %    predict_accuracy(o,1) = accuracy_L(1)/100;

        D = searchWindow(objbbox);

        flag = zeros(1,size(frames,4));
        objbbox = zeros(size(frames,4),4);
        objbbox(1,:) = objP(1,:);
        Length = size(frames,4);

        patch_width = objbbox(1,3); patch_height = objbbox(1,4);        

        for i = 2 : size(frames,4)
            i
            I = double(rgb2gray(uint8(frames(:,:,:,i))));

            if sum(isnan(objbbox(i-1,:)))==0
                bbox = ones(size(D,1),1)*objbbox(i-1,:) + D; % posible bboxes where the object is located in frame t + 1
                bbox(bbox(:,1)<1 | bbox(:,2)<1 | (bbox(:,1)+bbox(:,3)-1)>width | (bbox(:,2)+bbox(:,4)-1)>Height,:)=[];

                hogS_nxt = hogFeat(I,bbox);

                % NIQE calculation and NSS use decision
%                 quality = computequality(I,blocksizerow,blocksizecol,blockrowoverlap,blockcoloverlap,mu_prisparam,cov_prisparam);
%                 NSS = quality >= NIQE_threshold_array(thr);
%                 total_NIQE(o,i) = quality;

                if NSS
                    nssS_nxt = nssFeat(I,bbox) / Cs;
                    features_nxt = [hogS_nxt, nssS_nxt];  % Concatenation of NSS features to HOG features
                else
                    features_nxt = hogS_nxt;  % Only HOG features
                end
                
                if isempty(find(isnan(gtP(i,:)), 1))
                    gt_center = [gtP(i,1)+round(gtP(i,3)/2), gtP(i,2)+round(gtP(i,4)/2)];
                    gtP(i,:) = [gt_center(1)-round(patch_width/2), gt_center(2)-round(patch_height/2), patch_width, patch_height];

                    labels_gt = bboxOverlapRatio(gtP(i,:),bbox)>=0.7;
                    [labels, ~, ~] = svmpredict2(double(labels_gt'),features_nxt,model);
%                    predict_accuracy(o,i) = length(find(labels(labels_gt)))/length(find(labels_gt));                
                else
                    [labels, ~, ~] = svmpredict2(ones(size(bbox,1),1),features_nxt,model);
%                    predict_accuracy(o,i) = NaN;
                end

                objP_nxt = bbox(labels==1,:);
            else
                hogS_nxt = hogFeat(I,wP);
                                
                if NSS
                    nssS_nxt = nssFeat(I,wP) / Cs;
                    features_nxt = [hogS_nxt, nssS_nxt];  % Concatenation of NSS features to HOG features
                else
                    features_nxt = hogS_nxt;  % Only HOG features
                end
                
                if isempty(find(isnan(gtP(i,:)), 1))  
                    gt_center = [gtP(i,1)+round(gtP(i,3)/2), gtP(i,2)+round(gtP(i,4)/2)];
                    gtP(i,:) = [gt_center(1)-patch_width, gt_center(2)-patch_height, patch_width, patch_height];                    

                    labels_gt = bboxOverlapRatio(gtP(i,:),wP)>=0.7;
                    [labels, ~, ~] = svmpredict2(double(labels_gt'),features_nxt,model);
%                    predict_accuracy(o,i) = length(find(labels(labels_gt)))/length(find(labels_gt));               
                else
                    [labels, ~, ~] = svmpredict2(ones(size(wP,1),1),features_nxt,model);
%                    predict_accuracy(o,i) = NaN;
                end
                objP_nxt = wP(labels==1,:);        
            end

            if isempty(objP_nxt) && sum(isnan(objbbox(i-1,:)))==0
                flag(i) = 1;
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
                    objP_nxt = round([x0,y0,W1,H]);
                else
                    objP_nxt = [NaN,NaN,NaN,NaN];
                end
            end

            quality = computequality(I,blocksizerow,blocksizecol,blockrowoverlap,blockcoloverlap,mu_prisparam,cov_prisparam);
            NSS = quality >= NIQE_threshold_array(thr);
            total_NIQE(o,i) = quality;
            
            if ((sum(isnan(objP_nxt))==0) & (isempty(objP_nxt)==0))
                % object location estimation
                overlap  = (sum(bboxOverlapRatio(objP_nxt,objP_nxt))-1)';
                objP_nxt_= objP_nxt(overlap>=max(overlap)*0.8,:);
                objbbox(i,:)  = (size(objP_nxt,1)==1)*objP_nxt(1,:) + (1-(size(objP_nxt,1)==1))*round(median(objP_nxt_));

                % retrain SVM using bg classified patches
                if flag(i) == 0
        %                     if ~isempty(bgP_nxt)
        %                         [hogS] = bgUpdate(I,'msp',0.05,objbbox(i,:),bgP,bgKeys,hogS);
        %                         [hogS,bgPVar_init] = bgUpdate(I,'mvc',0.05,objbbox(i,:),bgP,bgPVar_init,hogS);                        

                        [hogS,~,nssS] = bgUpdateNSS(I,'mvc',0.05,objbbox(i,:),bgP,bgKeys,hogS,nssS,Cs);
                        
                        if ~NSS
                            i =  i;
                        end
%                         if NSS
%                             nssS   = nssFeat(I,[objP;bgP]) / Cs; 
%                             [hogS,~,nssS] = bgUpdateNSS(I,'mvc',0.05,objbbox(i,:),bgP,bgKeys,hogS,nssS,Cs);
%                         else
%                             [hogS] = bgUpdate(I,'mvc',0.05,objbbox(i,:),bgP,bgKeys,hogS);
%                         end

                        I_objP  = selectPatch(I,objbbox(i,:));
                        objCode = briefDescriptor(I_objP,points);
                        if min(pdist2(objCode,binCode,'hamming')) <= bgTsh4 
                            disp(':|')
                            hogSobj   = hogFeat(I,objbbox(i,:));
                            dist1_add = sqrt(sum((hogSobj - hogSobj_avg).^2,2));
                            if Nobj == Nobj_max
                                hogS(Nobj,:) = hogSobj;
                                objP(Nobj,:) = objbbox(i,:);
                                objFrames(Nobj) = i;
                                binCode(Nobj,:) = objCode;
                                dist1(Nobj)     = dist1_add;
%                                if NSS
                                    nssSobj   = nssFeat(I,objbbox(i,:)) / Cs;
                                    nssS(Nobj,:) = nssSobj;
%                                end
                            else
                                hogS    = [hogS(1:Nobj,:);hogSobj;hogS(Nobj+1:Nobj+Nbg,:)]; 
                                objP    = [objP;objbbox(i,:)];
                                objFrames = [objFrames;i];
                                binCode   = [binCode;objCode];                            
                                dist1     = [dist1_;dist1_add];
%                                if NSS
                                    nssSobj   = nssFeat(I,objbbox(i,:)) / Cs;
                                    nssS    = [nssS(1:Nobj,:);nssSobj;nssS(Nobj+1:Nobj+Nbg,:)]; 
%                                end
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

                        nssS(1:Nobj,:) = nssS(Idist1,:);
                        nssS(Nobj+1:Nobj+Nbg,:) = nssS(Idist2+Nobj,:);
                        
                        if NSS
                            featuresS = [hogS, nssS];  % Concatenation of NSS features to HOG features
                        else
                            featuresS = hogS;  % Only HOG features
                        end

                        model = svmtrain2([ones(Nobj,1);zeros(Nbg,1)],double(featuresS),'-t 0 -c 100');
                end
        %                 end
            else
        %                 vidOut(:,:,:,i) = frames(:,:,:,i);   
                objbbox(i,:) = [NaN,NaN,NaN,NaN];
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

            % Display each frame with the found object bounding box
%             title(['Frame ',num2str(i)]);
%             if object_found(i)
%                 imshow(uint8(drawPatches(frames(:,:,:,i),objboxdraw,1)));
%             else
%                 imshow(uint8(frames(:,:,:,i)));
%             end
        end
        [fs(o,thr),precision(o,thr),recall(o,thr),overlap] = fscore(objbbox,gtP);
        total_object_found(o,thr,:) = object_found;
        flag_lvl(o,thr,:) = flag;

%        thresh = 0.5;
        for thresh = 1:length(AOS_threshold_array)
            AOS_thresh = AOS_threshold_array(thresh);
            [AOS(o,thresh,thr), false_p(o,thresh,thr), ROC_accuracy(o,thresh,thr), ~] = AOS_score(objbbox,gtP,AOS_thresh);%
%        [AOS(o,thr), false_p(o,thr), ROC_accuracy(o,thr), ~] = AOS_score(objbbox,gtP,thresh);            
        end
%        close
    end
    %plot(1:Length,S_local(o,:),1:Length,predict_accuracy(o,:),1:Length,object_found,'bo',1:Length,flag,'*y');
end

toc

color_array = 'brmgck';

% for o = 1:length(Distortion)
%     %plot(false_p(o,:),ROC_accuracy(o,:),color_array(o),'DisplayName',num2str(o));
%     plot(NIQE_threshold_array,AOS(o,:),color_array(o),'DisplayName',Distortion{o});
% end
save(strcat('./Bovik_approach/Bovik_Video_',num2str(v),'_100frames'),'AOS','ROC_accuracy','false_p','fs','total_object_found','flag_lvl','total_NIQE','NIQE_threshold_array');        
for thr = 1:length(NIQE_threshold_array)
    figure;
    hold on
    
    for o = 1:length(Distortion)
        %plot(false_p(o,:),ROC_accuracy(o,:),color_array(o),'DisplayName',num2str(o));
        plot(AOS_threshold_array,ROC_accuracy(o,:,thr),color_array(o),'DisplayName',Distortion{o});
    end
    hold off
    
    title(sprintf('Video %u, NIQE threshold %.4f',v,NIQE_threshold_array(thr)));
    plot_ax = gca;
    plot_ax.FontSize = 16;        
    xlabel('Overlap threshold');
    ylabel('Success rate');
    legend('show','Location','northeast');
    saveas(gcf,strcat('./Bovik_approach/SP_Bovik_Video_',num2str(v),'_NIQEt_',num2str(thr)),'epsc');
    %close;
end

% title(sprintf('Video %u, AOS for NIQE approach',v));    
% 
% plot_ax = gca;
% plot_ax.FontSize = 16;        
% xlabel('NIQE threshold');
% ylabel('AOS (0.5 overlap)');
% legend('show','Location','southeast');
%saveas(gcf,strcat('./SVM_new_results/Video_',num2str(v),'_SP_',Distortion),'epsc');
%close;
save(strcat('./Bovik_approach/AOS_Bovik_Video_',num2str(v)),'AOS','ROC_accuracy','false_p','fs','total_object_found','flag_lvl','total_NIQE','NIQE_threshold_array');
close all
load gong.mat
sound (y, Fs);
