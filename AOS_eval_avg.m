function AOS_eval_avg(videos, Distortion)

% Generates averaged success plots of all test videos combined for a given
% distortion, with the three severity levels in the same plot

% videos = [1, 2, 4, 5, 6, 7, 8];
File_name_begin = './Results/MVC_Results_Video_';
AOS_threshold_array = linspace(0,1,100);
location_threshold_array = linspace(0,50,100);
if strcmp(Distortion,'pristine')
    Q_size = 1;
else
    Q_size = 3;
end
ROC_accuracy_all_pristine = zeros(size(videos,2),size(AOS_threshold_array, 2));
loc_precision_all_pristine = zeros(size(videos,2), size(location_threshold_array, 2));

color_array = 'brgmck';
marker_array = 'x*^sd';

% Distortion = 'Gaussian';

for i = 1:size(videos,2)
    load(strcat(File_name_begin,num2str(videos(i)),'_pristine'),'ROC_accuracy', 'location_precision');
    ROC_accuracy_all_pristine(i,:) = ROC_accuracy;
    loc_precision_all_pristine(i,:) = location_precision;
end

ROC_accuracy_avg_pristine = mean(ROC_accuracy_all_pristine);
loc_precision_avg_pristine = mean(loc_precision_all_pristine);

% ypos = max(ROC_accuracy_all_pristine)-ROC_accuracy_avg_pristine;
% yneg = ROC_accuracy_avg_pristine-min(ROC_accuracy_all_pristine);
% errorbar(AOS_threshold_array,ROC_accuracy_avg_pristine(1,:),yneg,ypos,'-ok','DisplayName','Pristine');
figure; plot(AOS_threshold_array,ROC_accuracy_avg_pristine(1,:),'-ok','DisplayName','Pristine');
hold on
roc_ax = gca;
figure; plot(location_threshold_array,loc_precision_avg_pristine(1,:),'-ok','DisplayName','Pristine');
hold on
loc_ax = gca;

if ~strcmp(Distortion,'pristine')
%     hold on
    ROC_accuracy_all = cell(3,1);
    loc_precision_all = cell(3,1);
    ROC_accuracy_avg = zeros(3,size(AOS_threshold_array,2));
    loc_precision_avg = zeros(3,size(location_threshold_array,2));

    for i = 1:size(videos,2)
        load(strcat(File_name_begin,num2str(videos(i)),'_',Distortion),'ROC_accuracy','location_precision');
        for k = 1:size(ROC_accuracy,1)
            ROC_accuracy_all{k} = [ROC_accuracy_all{k}; ROC_accuracy(k,:)];
        end    
        for k = 1:size(location_precision,1)
            loc_precision_all{k} = [loc_precision_all{k}; location_precision(k,:)];
        end            
    end

    for k = 1:size(ROC_accuracy,1)
        ROC_accuracy_avg(k,:) = mean(ROC_accuracy_all{k});
%         ypos = max(ROC_accuracy_all{k}) - ROC_accuracy_avg(k,:);
%         yneg = ROC_accuracy_avg(k,:) - min(ROC_accuracy_all{k});
%         errorbar(AOS_threshold_array,ROC_accuracy_avg(k,:),yneg,ypos,strcat('-',marker_array(k),color_array(k)),'DisplayName',num2str(k));
        plot(roc_ax, AOS_threshold_array,ROC_accuracy_avg(k,:),strcat('-',marker_array(k),color_array(k)),'DisplayName',num2str(k));
    end
    for k = 1:size(location_precision,1)
        loc_precision_avg(k,:) = mean(loc_precision_all{k});
        plot(loc_ax, location_threshold_array,loc_precision_avg(k,:),strcat('-',marker_array(k),color_array(k)),'DisplayName',num2str(k));
    end    
%     hold off    
    title(roc_ax, strcat('Success plot ', sprintf(' %s distortion',Distortion)));
    title(loc_ax, strcat('Precision plot ', sprintf(' %s distortion',Distortion)));
else
    title(roc_ax, 'Success plot pristine');
    title(loc_ax, 'Precision plot pristine');
end

xlabel(roc_ax, 'Overlap threshold');
ylabel(roc_ax, 'Success rate');
xlabel(loc_ax, 'Location error threshold');
ylabel(loc_ax, 'Precision');

legend(roc_ax, 'show','Location','southwest');
legend(loc_ax, 'show','Location','southeast');
% plot_ax = gca;
roc_ax.FontSize = 16; loc_ax.FontSize = 16;