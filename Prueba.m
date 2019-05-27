% for i=1:size(nss,2)
%     maxnss(i)=max(max(nss{i}(:,end-35:end)));
%     minnss(i)=min(min(nss{i}(:,end-35:end)));
% 
%     maxhog(i)=max(max(nss{i}(:,1:end-36)));
%     minhog(i)=min(min(nss{i}(:,1:end-36)));
% end
% 
% x=1:size(nss,2);
% 
% plot(x,maxnss,'b',x,minnss,'--b',x,maxhog,'g',x,minhog,'--g')



clear all; close all; clc;

path(path,'./functions')
path(path,'./MeanShift_Code')
path(path,'./bbox_configs')
path(path,'./matlab')
path(path,'./videos')

%% Data Base pristine videos
vidName = {'car',...        % 1
        'jumping',...       % 2
        'pedestrian1',...   % 3
        'pedestrian2',...   % 4
        'pedestrian3',...   % 5
        'charger',...       % 6
        'cameraJuan',...    % 7
        'gurgaon',...       % 8
        'basketball',...    % 9
        'david',...         % 10
        'carchase',...      % 11
        'sylvester',...     % 12
        'football',...      % 13
        'crowds',...        % 14
        'cardark',...       % 15
        'bolt2',...         % 16
        'coupon',...        % 17
        'dancer2',...       % 18
        'david2',...        % 19
        'david3',...        % 20
        'faceocc1',...      % 21
        'faceocc2',...      % 22
        'fish',...          % 23
        'football1',...     % 24
        'jogging',...       % 25
        'kitesurf',...      % 26
        'man',...           % 27
        'mhyang',...        % 28
        'mountainbike',...  % 29
        'subway'};          % 30
    
%%
video = 2;
distored_dataset = strcat('disroed_dataset_',vidName{video});


load(vidName{video},'frames')
load (distored_dataset)


numOfFrames = size(frames,4);
Height = size(frames,1);
width = size(frames,2);
imSize = [Height,width];

load(strcat(vidName{video},'_gt'),'gtP');
bboxName = strcat('bbox_',vidName{video});
load(bboxName);

for i=1:numOfFrames
    if size(frames,3)==3
        frames_pristine{i} = double(rgb2gray(uint8(frames(:,:,:,i))));
    else
        frames_pristine{i} = double(frames(:,:,:,i));
    end
end

% figure
% for i=1:numOfFrames
%    imshow(uint8(frames_pristine{i}));
% end
%% aplicacion de distorsiones sinteticas


%Distorsion - d
distorsion{1}='gaussian';
distorsion{2}='MPEG-4';
distorsion{3}='blur';
distorsion{4}='salt & pepper';
distorsion{5}='uneven illumination';


%Nivel de distorsion - n
Q{1} = [0.01, 0.05, 0.1];    % AWGN                      
Q{2} = [60, 30, 5];          % MPEG Compression
Q{3} = [1, 9, 15];           % Blur
Q{4} = [0.01, 0.05, 0.1];    % S & P
Q{5} = 1e-5*[1, 3, 5];       % uneven illumination


%% Calculo de los HOG y NSS Data set characteristics

patchFrame = videoPatch(gtP,frames,0); %0: Equal size patches, 1: Different Size patches 
%patchFrame1 = videoPatch(gtP,frames,1);
charac2 = 3; %1:HOG , 2:NSS, 3:HOG_NSS
charac1 = 1;

u_old=0;
st_old=0;
n_patch_old=0;

u=[];
st=[];
n=[];

[featuresS,u_old,st_old,n_patch_old] = hogNSSFeat(frames_pristine{1},patchFrame{1},0,1,2,u_old,st_old,n_patch_old);

        hogS = featuresS(:,1:end-36);
        nssS = featuresS(:,end-35:end);
% figure; 
% for i=1:numOfFrames
% [featMat,u_old,st_old,n_patch_old] = hogNSSFeat(frames_pristine{i},patchFrame{i},0,1,2,u_old,st_old,n_patch_old);
% u=[u_old];
% st=[st_old];
% n=[n_patch_old];
% 
% plot(u,'b'),hold on,
% plot(st,'red'),hold off,
% pause(0.5);
% end