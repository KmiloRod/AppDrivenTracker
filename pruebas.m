% Ing. Carlos Fernando Quiroga 10 / Apr / 2019
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

