function mat2avi(filename,videoMat,fs,profile,Quality)

if strcmp(profile,'MPEG-4') || strcmp(profile,'Motion JPEG AVI')
    vidObj	= VideoWriter(filename,profile);
    set(vidObj,'Quality',Quality);
else
    vidObj         = VideoWriter(filename,profile);
end
% numberOfFrames = size(videoMat,4);
vidObj.FrameRate = fs;
% vidObj.Height    = size(videoMat,1);
% vidObj.Width     = size(videoMat,2);

open(vidObj);
writeVideo(vidObj,videoMat)
close(vidObj);
% for i = 1 : numberOfFrames
%     writeVideo(vidObj,videoMat(:,:,:,i));    
% end













end