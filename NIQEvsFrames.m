v = 8;
File_name_begin = './Bovik_approach/Bovik_Video_';
load(strcat(File_name_begin,num2str(v),'_','100frames'),'total_NIQE');
Distortion = {'pristine','MPEG4','Gaussian','Blur','S & P'};
figure;
hold on
for i = 1:5
    plot(1:100,total_NIQE(i,:),'DisplayName',Distortion{i});
end
title(strcat('NIQE Video ',num2str(v),' (first 100 frames)'));
plot_ax = gca;
plot_ax.FontSize = 16;
xlabel('Frames');
ylabel('NIQE');
legend('show','Location','southeast');