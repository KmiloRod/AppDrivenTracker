function SVMaccVsFrames(v, Distortion, meanOnly)
% This function plots the video tracker SVM classifier accuracy vs frame
% number for a given video (if V is the index of one sequence), or a group
% of sequences (when V is an array of indices). DISTORTION is a string
% specifying the type of distortion applied. If MEANONLY has value 1, the
% function aditionally generates a plot averaging the SVM accuracy for all
% the videos in V, vs the frame number

figure; figBg = gca; hold on
figure; figObj = gca; hold on

if length(v) == 1
    load(strcat('../Results/MVC_Results_SVMacc_Video_',num2str(v),'_','pristine'))

    numOfFrames = size(total_object_found,2);

    if meanOnly == 0
        plot(figObj, 1:numOfFrames, predict_accuracy_obj,'DisplayName','0');
        plot(figBg, 1:numOfFrames, predict_accuracy_bg,'DisplayName','0');
    else
        plot(figObj, 1:numOfFrames, repmat(median(predict_accuracy_obj,'omitnan'), numOfFrames, 1), 'DisplayName','0');
        plot(figBg, 1:numOfFrames, repmat(median(predict_accuracy_bg,'omitnan'), numOfFrames, 1), 'DisplayName','0');
    end


    title(figObj, strcat('SVM object patches classification accuracy for video ',num2str(v), ', ', Distortion));
    title(figBg, strcat('SVM background patches classification accuracy for video ',num2str(v), ', ', Distortion));

    if strcmp(Distortion,'pristine')
        return
    end

    load(strcat('../Results/MVC_Results_SVMacc_Video_',num2str(v),'_',Distortion))
    distLevels = 1:size(predict_accuracy_obj,1);
    
    for o = distLevels
        if meanOnly == 0
            plot(figObj, 1:numOfFrames, predict_accuracy_obj(o,:),'DisplayName',num2str(o));
            plot(figBg, 1:numOfFrames, predict_accuracy_bg(o,:),'DisplayName',num2str(o));
        else
            plot(figObj, 1:numOfFrames, repmat(median(predict_accuracy_obj(o,:),'omitnan'), numOfFrames, 1), 'DisplayName',num2str(o));
            plot(figBg, 1:numOfFrames, repmat(median(predict_accuracy_bg(o,:),'omitnan'), numOfFrames, 1), 'DisplayName',num2str(o));
        end
    end
    ylabel(figObj, 'Prediction accuracy'); ylabel(figBg, 'Prediction accuracy');
    legend(figObj, 'show','Location','northeast'); legend(figBg, 'show','Location','northeast');
else
    mean_accuracy_obj_prst = []; mean_accuracy_bg_prst = [];
    mean_accuracy_obj_dist = []; mean_accuracy_bg_dist = [];
    for vid = v
        load(strcat('../Results/MVC_Results_SVMacc_Video_',num2str(vid),'_','pristine'))
        mean_accuracy_obj_prst = [mean_accuracy_obj_prst; median(predict_accuracy_obj,'omitnan')];
        mean_accuracy_bg_prst = [mean_accuracy_bg_prst; median(predict_accuracy_bg,'omitnan')];
     
        if strcmp(Distortion,'pristine')
            continue
        end

        load(strcat('../Results/MVC_Results_SVMacc_Video_',num2str(vid),'_',Distortion))
        distLevels = 1:size(predict_accuracy_obj,1);
        mean_temp_obj = []; mean_temp_bg = [];
        for o = distLevels
            mean_temp_obj = [mean_temp_obj, median(predict_accuracy_obj(o,:), 'omitnan')];
            mean_temp_bg = [mean_temp_bg, median(predict_accuracy_obj(o,:), 'omitnan')];
        end
        mean_accuracy_obj_dist = [mean_accuracy_obj_dist; mean_temp_obj];
        mean_accuracy_bg_dist = [mean_accuracy_bg_dist; mean_temp_bg];
    end
    if meanOnly == 0
        plot(figObj, 1:10, repmat(median(mean_accuracy_obj_prst), 10, 1),'DisplayName','0');
        plot(figBg, 1:10, repmat(median(mean_accuracy_bg_prst), 10, 1),'DisplayName','0');
        
        title(figObj, strcat('SVM object patches classification accuracy for all videos, ', Distortion));
        title(figBg, strcat('SVM background patches classification accuracy for all videos, ', Distortion));
        
        if strcmp(Distortion,'pristine')
            return
        end
        
        q = 1;
        for o = distLevels
            plot(figObj, 1:10, repmat(median(mean_accuracy_obj_dist(:,q)), 10, 1),'DisplayName',num2str(o));
            plot(figBg, 1:10, repmat(median(mean_accuracy_bg_dist(:,q)), 10, 1),'DisplayName',num2str(o));
            q = q + 1;
        end
        legend(figObj, 'show','Location','northeast'); legend(figBg, 'show','Location','northeast');
    else
        if strcmp(Distortion,'pristine')
            return
        end

        plot(figObj, [0, distLevels], [median(mean_accuracy_obj_prst), median(mean_accuracy_obj_dist)], 'DisplayName','0');
        plot(figBg, [0, distLevels], [median(mean_accuracy_bg_prst), median(mean_accuracy_bg_dist)], 'DisplayName','0');

        title(figObj, strcat('SVM object patches classification accuracy vs distortion level for all videos, ', Distortion));
        title(figBg, strcat('SVM background patches classification accuracy vs distortion level for all videos, ', Distortion));
        
        if strcmp(Distortion,'pristine')
            return
        end
        
        xlabel(figObj, 'Distortion level'); xlabel(figBg, 'Distortion level');   
    end 
    ylabel(figObj, 'Prediction accuracy'); ylabel(figBg, 'Prediction accuracy');
end
