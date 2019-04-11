% Ing. Carlos Fernando Quiroga 10 / Apr / 2019
%% Programa para extraer las caracteristicas hogs de los videos por cada frame


%Nota: para la funcion extraccionHogs que se va a desarrollar a partir de
%este codigo las variables de salida son:
%1. Arreglo tipo cell "hog" contiene todos los hogs calculados para cada frame
%en imagen pristina y con 5 clases de distorsiones.
%2. Etiquetado de las caracteristicas HOG
%3. Arreglo tipo cell "distorsiones" que contiene el tipo de distorsión y
%el orden en que son aplicadas.
%4. Q = arreglo tipo cell que indica el nivel de distorsion
%--------------------------------------------------------------------------
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
video = 7;
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

%Descomentar esta seccion si se va a correr el programa por primera vez,
%con un video diferente, hay que tener en cuenta que la variable
%frames_distored debe de ser guardada para acelerar el proceso de calculos
%posteriores.
% 
% for i=1:numOfFrames
%     i
%     f=1;
%     for d=1:size(distorsion,2)
%         for n=1:size(Q{d},2)
%             if isequal(distorsion{d},'gaussian')
%                 frames_d = vidnoise(uint8(frames_pristine{i}),distorsion{d},[0 Q{d}(n)]);
%                 frames_distored{i}{f} = uint8(frames_d);
%             elseif isequal(distorsion{d},'MPEG-4')
%                 frames_d = rgb2gray(vidnoise(uint8(frames_pristine{i}),distorsion{d},Q{d}(n)));
%                 frames_distored{i}{f} = uint8(frames_d);
%             else
%                 frames_d = vidnoise(uint8(frames_pristine{i}),distorsion{d},Q{d}(n));
%                 frames_distored{i}{f} = uint8(frames_d);
%             end 
%             f=f+1;
%         end
%     end
% end
% 
% distored_dataset = strcat('disroed_dataset_',vidName{video});
% save(distored_dataset,'frames_distored')
%% Calculo de los HOG Data set characteristics

patchFrame = videoPatch(gtP,frames);


%-------Calculo de los HOGs para los frames pristinos y distorsionados-----
% OJO: hay que tener en cuenta que el numero de HOGs varia frame a frame ya
% que los parches para cada frame varian

j=1;
k=[];% frames a los cuales no se les calculo las caracteristicas HOGs
%figure
for i = 1:numOfFrames
    i
    hog_distored{j}=[];
    
    if isempty(patchFrame{i}) == 0
        hog_pristine{j} = hogNSSFeat(frames_pristine{i},patchFrame{i},0,0);
        
        for d = 1 : size(frames_distored{i},2)
            hog_d = hogNSSFeat(frames_distored{i}{d},patchFrame{i},0,0);
            hog_distored{j}=cat(1,hog_distored{j},hog_d);
        end
        
        hog{j}=[hog_pristine{j};hog_distored{j}];
        
        %imshow(uint8((hog{j}/max(max(hog{j})))*255))
        
        j=j+1;
    else
        k=cat(1,k,i);
    end     
end



%% Dibuja la imagen y los parches en la imagen

figure
fr=1;
imshow(uint8(frames_pristine{fr})); hold on 
p = objP;
%p = gtP;

% p = patchFrame{fr};
% for i=2:size(patchFrame,2)
%     p=cat(1,p,patchFrame{i});
% end

for i=1:size(p,1)
    x1=[p(i,1), p(i,1)+p(i,3), p(i,1)+p(i,3), p(i,1), p(i,1)];
    y1=[p(i,2), p(i,2), p(i,2)+p(i,4), p(i,2)+p(i,4), p(i,2)];
    plot(x1,y1,'r-', 'LineWidth', 1)
end 





