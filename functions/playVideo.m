%% Play video
%% This function plays the videos saved a priori in the folder ./videos

function playVideo(video)
path(path,'./videos');
%6,7,8
%9
% Faltan en la base de datos: 11, 12, 13,14,
% 15,16,17,19,20,21,22,23,25,28,29,30
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

    load(vidName{video},'frames')
    numOfFrames = size(frames,4);

    for i=1:numOfFrames
        if size(frames,3)==3
            frames_pristine{i} = double(rgb2gray(uint8(frames(:,:,:,i))));
        else
            frames_pristine{i} = double(frames(:,:,:,i));
        end

    end
    figure
    for i=1:numOfFrames
       imshow(uint8(frames_pristine{i}));
    end

end