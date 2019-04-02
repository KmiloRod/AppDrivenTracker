%% Programa para extraer los hogs
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
    I = double(rgb2gray(uint8(frames(:,:,:,1))));
else
    I = double(frames(:,:,:,1));
end

save('Juan');
%imshow(uint8(I));

hogS   = hogNSSFeat(I,[objP;bgP],0,0);


