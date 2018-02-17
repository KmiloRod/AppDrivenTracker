function generateBboxVideoMP4(fileName,frames,object_bbox,quality,frame_rate)
% This function generates an AVI video file with each frame annotated with
% the target object bounding box resultant obtained from running a tracker
% on the video file with name FILENAME. The parameter QUALITY specifies
% the quality of the output video (0-100), and OBJECT_BBOX is a matrix
% containing the bounding boxes of the target object.

numOfFrames = size(frames,4);

wait_h = waitbar(0,'Adding bounding boxes to frames');
for i = 1:numOfFrames
    if sum(isnan(object_bbox(i,:)))==0
        I = drawPatches(frames(:,:,:,i),object_bbox(i,:),2);
        frames(:,:,:,i) = I;
    end
    waitbar(wait_h,sprinf('Adding bounding box to frame %u',i));
end
close(wait_h);

disp('Generating AVI video file. Please wait...');
mat2avi(fileName, frames, frame_rate, 'Motion JPEG AVI', quality);
disp('Done.');