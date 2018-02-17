%videos = [1, 2, 4, 5, 6, 7, 8];
videos = [2, 4, 5, 7, 8];
File_name_begin = 'Cs_Video_NSS_';
%AOS_threshold_array = linspace(0.1,1,19);
Q_size = 1;
%AOS_Cs_all_pristine = zeros(size(videos,2),size(Cs_array,2));
%Fs_Cs_all_pristine = zeros(size(videos,2),size(Cs_array,2));
% color_array = 'brgmck';
% marker_array = 'x*^sd';

Distortion = 'Gaussian';

for i = 1:size(videos,2)
    load(strcat(File_name_begin,num2str(videos(i)),'pristine'));
    AOS_Cs_all_pristine(i,:) = AOS_Cs;
    Fs_Cs_all_pristine(i,:) = Fs_Cs;
end

AOS_Cs_avg_pristine = mean(AOS_Cs_all_pristine);
Fs_Cs_avg_pristine = mean(Fs_Cs_all_pristine);

%plot(AOS_threshold_array,AOS_Cs_avg_pristine(1,:),'-k','DisplayName','Pristine');
semilogx(Cs_array,AOS_Cs_avg_pristine(1,:),'-k','DisplayName','Pristine');
ax_AOS = gca;
figure;
semilogx(Cs_array,Fs_Cs_avg_pristine(1,:),'-k','DisplayName','Pristine');
ax_Fs = gca;

if ~strcmp(Distortion,'pristine')
    hold(ax_AOS); hold(ax_Fs);
    AOS_Cs_all = zeros(size(videos,2),size(Cs_array,2));
    Fs_Cs_all = zeros(size(videos,2),size(Cs_array,2));
    %Fs_Cs_all = cell(3,1);
    %AOS_Cs_avg = zeros(1,size(Cs_array,2));

    for i = 1:size(videos,2)
        load(strcat(File_name_begin,num2str(videos(i)),Distortion));
        AOS_Cs_all(i,:) = AOS_Cs;
        Fs_Cs_all(i,:) = Fs_Cs;
    end

    AOS_Cs_avg = mean(AOS_Cs_all);
    Fs_Cs_avg = mean(Fs_Cs_all);
    %plot(AOS_threshold_array,AOS_Cs_avg(k,:),strcat('-',marker_array(k),color_array(k)),'DisplayName',num2str(k));
    semilogx(ax_AOS,Cs_array,AOS_Cs_avg,'g','DisplayName',Distortion);
    semilogx(ax_Fs,Cs_array,Fs_Cs_avg,'r','DisplayName',Distortion);

    hold(ax_AOS); hold(ax_Fs); 
    title(ax_AOS,sprintf('Average AOS vs Cs with %s distortion',Distortion));
    title(ax_Fs,sprintf('Average F-Score vs Cs with %s distortion',Distortion));
else
    title(ax_AOS,sprintf('Average AOS pristine vs Cs'));
    title(ax_Fs,sprintf('Average F-Score pristine vs Cs'));
end

xlabel(ax_AOS,'Cs'); xlabel(ax_Fs,'Cs');
ylabel(ax_AOS,'AOS'); ylabel(ax_Fs,'F-Score');
legend(ax_AOS,'show','Location','southeast');
legend(ax_Fs,'show','Location','southeast');
%plot_ax = gca;
ax_AOS.FontSize = 16;        
ax_Fs.FontSize = 16;        