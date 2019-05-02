% Ing. Carlos Fernando Quiroga 10 / Apr / 2019
%% Programa para extraer las caracteristicas hogs de los videos por cada frame


% CLASES: 
% 1 Imagenes pristinas
% 2 Distorsion gaussian
% 3 Distorsion MPEG-4
% 4 Distorsion blur
% 5 Distorsion salt & pepper
% 6 Distorsion uneven illumination
%--------------------------------------------------------------------------

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

% Generate distorted version of the video

% frames_distored = distoredDataset(frames_pristine,numOfFrames,distorsion,Q);
% 
% distored_dataset = strcat('disroed_dataset_',vidName{video});
% save(distored_dataset,'frames_distored')
%% Calculo de los HOG y NSS Data set characteristics

patchFrame0 = videoPatch(gtP,frames,0); %0: Equal size patches, 1: Different Size patches 
%patchFrame1 = videoPatch(gtP,frames,1);
charac2 = 2; %1:HOG , 2:NSS, 3:HOG_NSS
charac1 = 1;

[nss,k]=hog_nss(numOfFrames,patchFrame0,frames_pristine,frames_distored, charac2);
%[hog0]=hog_nss(numOfFrames,patchFrame0,frames_pristine,frames_distored, charac1);


%[nss1]=hog_nss(numOfFrames,patchFrame1,frames_pristine,frames_distored, charac2);
%[hog1]=hog_nss(numOfFrames,patchFrame1,frames_pristine,frames_distored, charac1);
%[hognss, k]=hog_nss(numOfFrames,patchFrame,frames_pristine,frames_distored, 3);
%% Dibuja la imagen y los parches en la imagen

% figure
% fr=1;
% imshow(uint8(frames_pristine{fr})); hold on 
% p = objP;

%p = gtP;

% p = patchFrame{fr};
% for i=2:size(patchFrame,2)
%     p=cat(1,p,patchFrame{i});
% end

% for i=1:size(p,1)
%     x1=[p(i,1), p(i,1)+p(i,3), p(i,1)+p(i,3), p(i,1), p(i,1)];
%     y1=[p(i,2), p(i,2), p(i,2)+p(i,4), p(i,2)+p(i,4), p(i,2)];
%     plot(x1,y1,'r-', 'LineWidth', 1)
% end 





