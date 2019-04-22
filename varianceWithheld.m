% Ing. Carlos Fernando Quiroga 15 / Apr / 2019
%This script graphs the percentages of variance retained from the PCA 
%reductions of 2 and 3 components

load('pvar/pvar202.mat')
load('pvar/pvar203.mat')
load('pvar/pvar212.mat')
load('pvar/pvar213.mat')
load('pvar/pvar602.mat')
load('pvar/pvar603.mat')
load('pvar/pvar612.mat')
load('pvar/pvar613.mat')
load('pvar/pvar702.mat')
load('pvar/pvar703.mat')
load('pvar/pvar712.mat')
load('pvar/pvar713.mat')

figure
plot(1:1:size(Pvar202,2),Pvar202,...
     1:1:size(Pvar212,2),Pvar212,...
     1:1:size(Pvar203,2),Pvar203,...
     1:1:size(Pvar213,2),Pvar213);
legend('= size Patch 2D','/= size Patch 2D','= size Patch 3D','/= size Patch 3D');
xlabel('Frames');ylabel('percentage');
title('percentage of variance withheld Video 2');

figure
plot(1:1:size(Pvar602,2),Pvar602,...
     1:1:size(Pvar612,2),Pvar612,...
     1:1:size(Pvar603,2),Pvar603,...
     1:1:size(Pvar613,2),Pvar613);
legend('= size Patch 2D','/= size Patch 2D','= size Patch 3D','/= size Patch 3D');
xlabel('Frames');ylabel('percentage');
title('percentage of variance withheld Video 6');


figure
plot(1:1:size(Pvar702,2),Pvar702,...
     1:1:size(Pvar712,2),Pvar712,...
     1:1:size(Pvar703,2),Pvar703,...
     1:1:size(Pvar713,2),Pvar713);
legend('= size Patch 2D','/= size Patch 2D','= size Patch 3D','/= size Patch 3D');
xlabel('Frames');ylabel('percentage');
title('percentage of variance withheld video 7');


max2=[max(Pvar203-Pvar202) max(Pvar213-Pvar212)];
min2=[min(Pvar203-Pvar202) min(Pvar213-Pvar212)];

max6=[max(Pvar603-Pvar602) max(Pvar613-Pvar612)];
min6=[min(Pvar603-Pvar602) min(Pvar613-Pvar612)];

max7=[max(Pvar703-Pvar702) max(Pvar713-Pvar712)];
min7=[min(Pvar703-Pvar702) min(Pvar713-Pvar712)];

%% Boxplots

%Note: To run this part of the code it is necessary to equalize the vectors 
%of the percentage of variation retained, for this case, this procedure is 
%done manually and the values to be supplemented are the means of each vector.

% sizemax2=max([size(Pvar202,2),size(Pvar203,2),size(Pvar212,2),size(Pvar213,2)]);
% sizemax6=max([size(Pvar602,2),size(Pvar603,2),size(Pvar612,2),size(Pvar613,2)]);
% sizemax7=max([size(Pvar702,2),size(Pvar703,2),size(Pvar712,2),size(Pvar713,2)]);
% 
% 

figure
boxplot([Pvar202', Pvar212', Pvar203', Pvar213'],'Notch','on','Labels',...
        {'= size Patch 2D','/= size Patch 2','= size Patch 3D','/= size Patch 3D'})
title('boxplot of percentage of variance withheld video: jumping')
ylabel('Percentage');

figure
boxplot([Pvar602', Pvar612', Pvar603', Pvar613'],'Notch','on','Labels',...
        {'= size Patch 2D','/= size Patch 2','= size Patch 3D','/= size Patch 3D'})
title('boxplot of percentage of variance withheld video: charger')
ylabel('Percentage');

figure
boxplot([Pvar702', Pvar712', Pvar703', Pvar713'],'Notch','on','Labels',...
        {'= size Patch 2D','/= size Patch 2','= size Patch 3D','/= size Patch 3D'})
title('boxplot of percentage of variance withheld video: cameraJuan')
ylabel('Percentage');
