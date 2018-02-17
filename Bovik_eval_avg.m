% Generates averaged success plots of all test videos combined for a given
% NIQE threshold value

videos = [1, 2, 4, 5, 6, 7, 8];
File_name_begin = './Bovik_approach/Bovik_Video_';
AOS_threshold_array = linspace(0.1,1,19);
NIQE_threshold_array = linspace(4,30,10);
Distortion = {'pristine','MPEG4','Gaussian','Blur','S & P'};
color_array = 'brgmck';
marker_array = 'x*^sd';

%ROC_accuracy_all = cell(5,1);
ROC_accuracy_all = zeros(size(videos,2),size(AOS_threshold_array,2),size(NIQE_threshold_array,2),size(Distortion,2));
ROC_accuracy_avg = zeros(size(NIQE_threshold_array,2),size(AOS_threshold_array,2),size(Distortion,2));

for i = 1:size(videos,2)
    load(strcat(File_name_begin,num2str(videos(i)),'_','100frames'),'ROC_accuracy');
    for k = 1:size(Distortion,2)
        for j = 1:size(NIQE_threshold_array,2)
            ROC_accuracy_all(i,:,j,k) = ROC_accuracy(k,:,j);
        end
    end    
end

for j = 1:size(NIQE_threshold_array,2)
    figure;
    hold on
    for k = 1:size(Distortion,2)
        ROC_accuracy_avg(j,:,k) = mean(ROC_accuracy_all(:,:,j,k));
        plot(AOS_threshold_array,ROC_accuracy_avg(j,:,k),strcat('-',marker_array(k),color_array(k)),'DisplayName',Distortion{k});
    end
    hold off
    title(sprintf('All videos, NIQE threshold %.4f',NIQE_threshold_array(j)));
    xlabel('Overlap threshold');
    ylabel('Success rate');
    legend('show','Location','northeast');
    plot_ax = gca;
    plot_ax.FontSize = 16;        
    saveas(gcf,strcat('./Bovik_approach/SP_Bovik_AllVideos_','_NIQEt_',num2str(j)),'epsc');
end



