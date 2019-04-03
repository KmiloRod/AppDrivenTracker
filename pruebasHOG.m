%% Programa para extraer los hogs

% CLASES: 
% 1 Imagenes pristinas
% 2 Distorsion MPEG-4
% 3 Distorsion gaussian
% 4 Distorsion blur
% 5 Distorsion salt & pepper
% 6 Distorsion uneven illumination

clear all; close all; clc;

path(path,'./functions')
path(path,'./MeanShift_Code')
path(path,'./bbox_configs')
path(path,'./matlab')
path(path,'./videos')

load('cameraJuan','frames')

numOfFrames = size(frames,4);
Height = size(frames,1);
width = size(frames,2);
imSize = [Height,width];

load(strcat('cameraJuan','_gt'),'gtP');
bboxName = strcat('bbox_','cameraJuan');
load(bboxName);

if size(frames,3)==3
    frames_pristine = double(rgb2gray(uint8(frames(:,:,:,1))));
else
    frames_pristine = double(frames(:,:,:,1));
end

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

f=1;

for d=1:size(distorsion,2)
    for n=1:size(Q{d},2)
        if isequal(distorsion{d},'gaussian')
            frames_d = vidnoise(uint8(frames_pristine),distorsion{d},[0 Q{d}(n)]);
            frames_distored{f} = uint8(frames_d);
%             figure
%             imshow(frames_distored{f})
        elseif isequal(distorsion{d},'MPEG-4')
            frames_d = rgb2gray(vidnoise(uint8(frames_pristine),distorsion{d},[0 Q{d}(n)]));
            frames_distored{f} = uint8(frames_d);
        else
            frames_d = vidnoise(uint8(frames_pristine),distorsion{d},Q{d}(n));
            frames_distored{f} = uint8(frames_d);
%             figure
%             imshow(frames_distored{f})
        end 
        f=f+1;
    end
end


%% Calculo de los HOG Data set characteristics

hog_pristine = hogNSSFeat(frames_pristine,objP,0,0);
hog=hog_pristine;

for i = 1:size(frames_distored,2)
    hog_distored = hogNSSFeat(frames_distored{i},objP,0,0);
    hog=cat(1,hog,hog_distored);
end

%imshow(uint8((hog/max(max(hog)))*255))




%% Dibuja la imagen y los parches en la imagen

figure
imshow(uint8(frames_pristine)); hold on 
p = objP;

for i=1:size(p,1)
    x=[p(i,1), p(i,1)+p(i,3), p(i,1)+p(i,3), p(i,1), p(i,1)];
    y=[p(i,2), p(i,2), p(i,2)+p(i,4), p(i,2)+p(i,4), p(i,2)];
    plot(x,y,'r-', 'LineWidth', 1)
end 





