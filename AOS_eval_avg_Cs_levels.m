% Generates averaged success plots per severity level of a given
% distortion ft all test videos combined, considering NSS
clear;
Cs = 1;
videos = [1, 2, 4, 5, 6, 7, 8];
%File_name_begin_NSS = 'AOS_NSS_Video_';
%File_name_begin_HOG = 'AOS_HOG_Video_';
File_name_begin_HOG = './Subtracted/AOS_HOG_Sub_Video_';
File_name_begin_NSS = './Subtracted/AOS_NSS_Sub_Video_';
AOS_threshold_array = linspace(0.1,1,19);
Q_size = 3;
ROC_accuracy_all_pristine = zeros(size(videos,2),size(AOS_threshold_array,2));
color_array = 'rgmck';
marker_array = 'x*^sd';

Distortion = 'MPEG4';


for i = 1:size(videos,2)
    load(strcat(File_name_begin_HOG,num2str(videos(i)),'_pristine'),'ROC_accuracy');
    ROC_accuracy_all_pristine(i,:) = ROC_accuracy;
end

ROC_accuracy_avg_pristine = mean(ROC_accuracy_all_pristine);

if ~strcmp(Distortion,'pristine')
    for i = 1:Q_size
        figure;
        handles_array(i) = gca;
        plot(handles_array(i),AOS_threshold_array,ROC_accuracy_avg_pristine(1,:),'-db','DisplayName','Pristine only HOG');
        hold(handles_array(i),'on');
    end
else
    figure;
    plot(AOS_threshold_array,ROC_accuracy_avg_pristine(1,:),'-db','DisplayName','Pristine only HOG');    
    hold on
end

for i = 1:size(videos,2)
    load(strcat(File_name_begin_NSS,num2str(videos(i)),'_pristine_Cs',num2str(Cs)),'ROC_accuracy');
    ROC_accuracy_all_pristine(i,:) = ROC_accuracy;
end

ROC_accuracy_avg_pristine = mean(ROC_accuracy_all_pristine);

if ~strcmp(Distortion,'pristine')    
    for i = 1:Q_size
        plot(handles_array(i),AOS_threshold_array,ROC_accuracy_avg_pristine(1,:),'-ok','DisplayName','Pristine with NSS');
    end
else
    plot(AOS_threshold_array,ROC_accuracy_avg_pristine(1,:),'-ok','DisplayName','Pristine with NSS');
end

if ~strcmp(Distortion,'pristine')
    ROC_accuracy_all = cell(3,1);
    ROC_accuracy_avg = zeros(3,size(AOS_threshold_array,2));

    for i = 1:size(videos,2)
        load(strcat(File_name_begin_HOG,num2str(videos(i)),'_',Distortion),'ROC_accuracy');
        for k = 1:size(ROC_accuracy,1)
            ROC_accuracy_all{k} = [ROC_accuracy_all{k}; ROC_accuracy(k,:)];
        end    
    end

    for k = 1:Q_size
        ROC_accuracy_avg(k,:) = mean(ROC_accuracy_all{k});
        plot(handles_array(k),AOS_threshold_array,ROC_accuracy_avg(k,:),'-xr','DisplayName',strcat('Level  ',num2str(k),' only HOG'));
    end


    for i = 1:size(videos,2)
        load(strcat(File_name_begin_NSS,num2str(videos(i)),'_',Distortion,'_Cs',num2str(Cs)),'ROC_accuracy');
        for k = 1:size(ROC_accuracy,1)
            ROC_accuracy_all{k} = [ROC_accuracy_all{k}; ROC_accuracy(k,:)];
        end    
    end

    for k = 1:Q_size
        ROC_accuracy_avg(k,:) = mean(ROC_accuracy_all{k});
        plot(handles_array(k),AOS_threshold_array,ROC_accuracy_avg(k,:),'-*g','DisplayName',strcat('Level  ',num2str(k),' with NSS'));
        hold(handles_array(k),'off');
        title(handles_array(k),sprintf('%s distortion, level %u, Cs = %u',Distortion,k,Cs));
        xlabel(handles_array(k),'Overlap threshold');
        ylabel(handles_array(k),'Success rate');
        legend(handles_array(k),'show','Location','southwest');
        handles_array(k).FontSize = 16;
    end   
else
    title(sprintf('Pristine Cs = %u',Cs));
    xlabel('Overlap threshold');
    ylabel('Success rate');
    legend('show','Location','southwest');
    plot_ax = gca;
    plot_ax.FontSize = 16;    
end
