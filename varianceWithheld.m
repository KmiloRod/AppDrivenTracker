% Ing. Carlos Fernando Quiroga 15 / Apr / 2019
%This script graphs the percentages of variance retained from the PCA 
%reductions of 2 and 3 components
clear all; close all; clc;
char = 2; % type of characteristic, HOGs or NSS

switch char
    case 1
        load('pvar/pvarhog202.mat') %name + 202 = 2:second video, 0: equal size patch, 2: 2 Dimension
        load('pvar/pvarhog203.mat')
        load('pvar/pvarhog212.mat')
        load('pvar/pvarhog213.mat') 
        load('pvar/pvarhog602.mat')
        load('pvar/pvarhog603.mat')
        load('pvar/pvarhog612.mat')
        load('pvar/pvarhog613.mat') %name + 613 = 6:sixth video, 1: diferent size patch, 3: 3 Dimension
        load('pvar/pvarhog702.mat')
        load('pvar/pvarhog703.mat')
        load('pvar/pvarhog712.mat')
        load('pvar/pvarhog713.mat')
    case 2
        load('pvar/pvarnss202.mat')
        load('pvar/pvarnss203.mat')
        load('pvar/pvarnss212.mat')
        load('pvar/pvarnss213.mat')
        load('pvar/pvarnss602.mat')
        load('pvar/pvarnss603.mat')
        load('pvar/pvarnss612.mat')
        load('pvar/pvarnss613.mat')
        load('pvar/pvarnss702.mat')
        load('pvar/pvarnss703.mat')
        load('pvar/pvarnss712.mat')
        load('pvar/pvarnss713.mat')
end
        figure
        plot(1:1:size(Pvar202,2),Pvar202,...
             1:1:size(Pvar212,2),Pvar212,...
             1:1:size(Pvar203,2),Pvar203,...
             1:1:size(Pvar213,2),Pvar213);
        legend('= size Patch 2D','/= size Patch 2D','= size Patch 3D','/= size Patch 3D');
        xlabel('Frames');ylabel('percentage');
        title('percentage of variance withheld Video jumping');

        figure
        plot(1:1:size(Pvar602,2),Pvar602,...
             1:1:size(Pvar612,2),Pvar612,...
             1:1:size(Pvar603,2),Pvar603,...
             1:1:size(Pvar613,2),Pvar613);
        legend('= size Patch 2D','/= size Patch 2D','= size Patch 3D','/= size Patch 3D');
        xlabel('Frames');ylabel('percentage');
        title('percentage of variance withheld Video charger');


        figure
        plot(1:1:size(Pvar702,2),Pvar702,...
             1:1:size(Pvar712,2),Pvar712,...
             1:1:size(Pvar703,2),Pvar703,...
             1:1:size(Pvar713,2),Pvar713);
        legend('= size Patch 2D','/= size Patch 2D','= size Patch 3D','/= size Patch 3D');
        xlabel('Frames');ylabel('percentage');
        title('percentage of variance withheld video cameraJuan');


        max2=[max(Pvar203-Pvar202) max(Pvar213-Pvar212)];
        min2=[min(Pvar203-Pvar202) min(Pvar213-Pvar212)];

        max6=[max(Pvar603-Pvar602) max(Pvar613-Pvar612)];
        min6=[min(Pvar603-Pvar602) min(Pvar613-Pvar612)];

        max7=[max(Pvar703-Pvar702) max(Pvar713-Pvar712)];
        min7=[min(Pvar703-Pvar702) min(Pvar713-Pvar712)];

        %% Boxplots

        %Note: To run this part of the code it is necessary to equalize the vectors 
        %of the percentage of variation retained, for this case, this procedure is 
        %done automatic and the values to be supplemented are the means of each vector.

        sizemax2=max([size(Pvar202,2),size(Pvar203,2),size(Pvar212,2),size(Pvar213,2)]);
        sizemax6=max([size(Pvar602,2),size(Pvar603,2),size(Pvar612,2),size(Pvar613,2)]);
        sizemax7=max([size(Pvar702,2),size(Pvar703,2),size(Pvar712,2),size(Pvar713,2)]);
         
        sizemax=[sizemax2,sizemax6,sizemax7];
        
        Pvar={Pvar202,Pvar212,Pvar203,Pvar213,...
              Pvar602,Pvar612,Pvar603,Pvar613,...
              Pvar702,Pvar712,Pvar703,Pvar713};
        
        for i=1:size(Pvar,2)
            if i<=4
                j=1;
                if size(Pvar{i},2) < sizemax(j)
                    m=mean(Pvar{i});
                    s=size(Pvar{i},2);
                    Pvar{i}(1,s+1:sizemax(j))=m;
                end
            elseif i>4 && i<=8
                j=2;
                if size(Pvar{i},2) < sizemax(j)
                    m=mean(Pvar{i});
                    s=size(Pvar{i},2);
                    Pvar{i}(1,s+1:sizemax(j))=m;
                end
            elseif i>8 && i<=12
                j=3;
                if size(Pvar{i},2) < sizemax(j)
                    m=mean(Pvar{i});
                    s=size(Pvar{i},2);
                    Pvar{i}(1,s+1:sizemax(j))=m;
                end
            end
        end

        figure
        boxplot([Pvar{1}', Pvar{2}', Pvar{3}', Pvar{4}'],'Notch','on','Labels',...
                {'= size Patch 2D','/= size Patch 2','= size Patch 3D','/= size Patch 3D'})
        title('boxplot of percentage of variance withheld video: jumping')
        ylabel('Percentage');

        figure
        boxplot([Pvar{5}', Pvar{6}', Pvar{7}', Pvar{8}'],'Notch','on','Labels',...
                {'= size Patch 2D','/= size Patch 2','= size Patch 3D','/= size Patch 3D'})
        title('boxplot of percentage of variance withheld video: charger')
        ylabel('Percentage');

        figure
        boxplot([Pvar{9}', Pvar{10}', Pvar{11}', Pvar{12}'],'Notch','on','Labels',...
                {'= size Patch 2D','/= size Patch 2','= size Patch 3D','/= size Patch 3D'})
        title('boxplot of percentage of variance withheld video: cameraJuan')
        ylabel('Percentage')
        
 %% Curves of variance withheld percentage. 
 
 
for i=1:size(nss0{1},2)
    [~, N0]= PCA_(nss0,i);
    [~, N1]= PCA_(nss1,i);
    Pvarmn0(i)=median(N0);
    Pvarmn1(i)=median(N1);

end
figure
plot(Pvarmn0), hold on;
plot(Pvarmn1), hold on;
title('Variance Withheld Porcentage NSS');
xlabel('Principal Components Quantity');
ylabel('Median of Porcentage');
legend('= Size Patches', '=/ Size Patches');
grid on;


for i=1:100%size(hog0{1},2)
    [~, H0]= PCA_(hog0,i);
    [~, H1]= PCA_(hog1,i);
    Pvarmh0(i)=median(H0);
    Pvarmh1(i)=median(H1);
    i
end
figure
plot(Pvarmh0), hold on;
plot(Pvarmh1), hold on;

title('Variance Withheld Porcentage HOG');
xlabel('Principal Components Quantity');
ylabel('Median of Porcentage');
legend('= Size Patches', '=/ Size Patches');
grid on;

