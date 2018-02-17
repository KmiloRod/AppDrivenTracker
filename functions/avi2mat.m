function vidMat = avi2mat(filename)

video  = VideoReader(filename);
% fs     = get(video, 'FrameRate');
vidMat = read(video);
% close(video)

end