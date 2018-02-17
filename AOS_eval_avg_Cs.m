% Generates averaged success plots of all test videos combined for a given
% distortion, with the three severity levels in the same plot, considering
% NSS results
clear;
Cs = 10;
videos = [1, 2, 4, 5, 6, 7, 8];
File_name_begin_HOG = './Subtracted/AOS_HOG_Sub_Video_';
File_name_begin_NSS = './AOS_NSS_Video_';
AOS_threshold_array = linspace(0.1,1,19);
Q_size = 3;
ROC_accuracy_all_pristine = zeros(size(videos,2),size(AOS_threshold_array,2));
color_array = 'brgmck';
marker_array = 'x*^sd';

Distortion = 'pristine';

% HOG plots
for i = 1:size(videos,2)
    load(strcat(File_name_begin_HOG,num2str(videos(i)),'_pristine'),'ROC_accuracy');
    ROC_accuracy_all_pristine(i,:) = ROC_accuracy;
end

ROC_accuracy_avg_pristine = mean(ROC_accuracy_all_pristine);

figure;
plot(AOS_threshold_array,ROC_accuracy_avg_pristine(1,:),'-ok','DisplayName','Pristine');

if ~strcmp(Distortion,'pristine')
    hold on
    ROC_accuracy_all = cell(3,1);
    ROC_accuracy_avg = zeros(3,size(AOS_threshold_array,2));

    for i = 1:size(videos,2)
        load(strcat(File_name_begin_HOG,num2str(videos(i)),'_',Distortion),'ROC_accuracy');
        for k = 1:size(ROC_accuracy,1)
            ROC_accuracy_all{k} = [ROC_accuracy_all{k}; ROC_accuracy(k,:)];
        end    
    end

    for k = 1:size(ROC_accuracy,1)
        ROC_accuracy_avg(k,:) = mean(ROC_accuracy_all{k});
        plot(AOS_threshold_array,ROC_accuracy_avg(k,:),strcat('-',marker_array(k),color_array(k)),'DisplayName',num2str(k));
    end
    hold off    
    title(sprintf('%s distortion only HOG',Distortion));
else
    title(sprintf('Pristine only HOG'));
end

xlabel('Overlap threshold');
ylabel('Success rate');
legend('show','Location','southwest');
plot_ax = gca;
plot_ax.FontSize = 16;        


% NSS plots
for i = 1:size(videos,2)
    load(strcat(File_name_begin_NSS,num2str(videos(i)),'_pristine','_Cs',num2str(Cs)),'ROC_accuracy');
    ROC_accuracy_all_pristine(i,:) = ROC_accuracy;
end

ROC_accuracy_avg_pristine = mean(ROC_accuracy_all_pristine);

figure;
plot(AOS_threshold_array,ROC_accuracy_avg_pristine(1,:),'-ok','DisplayName','Pristine');

if ~strcmp(Distortion,'pristine')
    hold on
    ROC_accuracy_all = cell(3,1);
    ROC_accuracy_avg = zeros(3,size(AOS_threshold_array,2));

    for i = 1:size(videos,2)
        load(strcat(File_name_begin_NSS,num2str(videos(i)),'_',Distortion,'_Cs',num2str(Cs)),'ROC_accuracy');
        for k = 1:size(ROC_accuracy,1)
            ROC_accuracy_all{k} = [ROC_accuracy_all{k}; ROC_accuracy(k,:)];
        end    
    end

    for k = 1:size(ROC_accuracy,1)
        ROC_accuracy_avg(k,:) = mean(ROC_accuracy_all{k});
        plot(AOS_threshold_array,ROC_accuracy_avg(k,:),strcat('-',marker_array(k),color_array(k)),'DisplayName',num2str(k));
    end
    hold off    
    title(sprintf('%s distortion with NSS',Distortion));
else
    title(sprintf('Pristine with NSS'));
end

xlabel('Overlap threshold');
ylabel('Success rate');
legend('show','Location','southwest');
plot_ax = gca;
plot_ax.FontSize = 16;        