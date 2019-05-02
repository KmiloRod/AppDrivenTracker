% Ing. Carlos Fernando Quiroga Ruiz 22/Apr/2019
% This function generates an array (cell) where all the distorted videos 
% are with the synthesized distortions that have been programmed.
% 
% 2 Gaussian distortion
% 3 Distorsion MPEG-4
% 4 Distorsion blur
% 5 Distorsion salt & pepper
% 6 Distorsion uneven illumination
% 
% The function has as input parameters:
% numOfFrames: Is the number of frames that the video has (int)
% frames_pristine: These are the pristine frames of the whole video (cell)
% distortion: It is an arrangement which contains the name of the distortions  
% that you want to apply (cell)
% Q: It is an arrangement which contains the distortion levels for each distortion.
% 
% The function has as output parameters:
% frames_distored: Cell type arrangement where all the distorted videos are 
% found by level, distortion and frame by frame
% 
% IT IS RECOMMENDED THAT IF YOU ARE GOING TO WORK WITH THE RESULT OF THIS 
% FUNCTION, SAVE IT, BECAUSE IT IS A DELAYED ROUTINE.

function frames_distored = distoredDataset(frames_pristine,numOfFrames,distorsion,Q)

    for i=1:numOfFrames
        porcentage=ceil(i*100/numOfFrames)
        f=1;
        for d=1:size(distorsion,2)
            for n=1:size(Q{d},2)
                if isequal(distorsion{d},'gaussian')
                    frames_d = vidnoise(uint8(frames_pristine{i}),distorsion{d},[0 Q{d}(n)]);
                    frames_distored{i}{f} = uint8(frames_d);
                elseif isequal(distorsion{d},'MPEG-4')
                    frames_d = rgb2gray(vidnoise(uint8(frames_pristine{i}),distorsion{d},Q{d}(n)));
                    frames_distored{i}{f} = uint8(frames_d);
                else
                    frames_d = vidnoise(uint8(frames_pristine{i}),distorsion{d},Q{d}(n));
                    frames_distored{i}{f} = uint8(frames_d);
                end 
                f=f+1;
            end
        end
    end

end 