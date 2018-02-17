function [vidMat_n] = vidnoise(vidMat,type,param)

% vidMat: RGB video sequence or RGB image

% type: 'gaussian', 'salt & pepper', 'Motion JPEG 2000', 'blur', 'uneven
% illumination'

% param is an 1-D-array which depends on type:
% for 'gaussian' param = [m v] where m is the mean of a 1-D gaussian pdf
% and v its vairance.
% for 'salt & pepper' param = d where d is the percentage of pixels
% affected in a frame. 
% for 'Motion JPEG 2000' param = Q where Q is a quality factor which takes
% values from 0 to 100, being 0 the lowest quality and 100 the highest one.
% for blur param = [sigma wsize] where sigma is the standard daviation of a
% 1-D gaussian PDF and wsize is the window size of square window.
% for univen illumination param = sigma where sigma is the spread parameter
% of a 2-D gaussian illumination mask which is multiplied by the input image.

numberOfFrames = size(vidMat,4);
vidMat_n       = zeros(size(vidMat));
switch type
    case 'gaussian'
        m = param(1); % mean
        v = param(2); % variance
        for i = 1 : numberOfFrames
            vidMat_n(:,:,:,i) = imnoise(vidMat(:,:,:,i),type,m,v);
        end       
    case 'salt & pepper'
        d = param(1); % percentage of affected pixels in a frame
        for i = 1 : numberOfFrames
            vidMat_n(:,:,:,i) = imnoise(vidMat(:,:,:,i),type,d);
        end       
    case 'Motion JPEG AVI'
        Q  = param(1); % quality factor
        fs = 30;
        if numberOfFrames > 1
            mat2avi('tmp.avi',vidMat,fs,type,Q);     
            vidMat_n = avi2mat('tmp.avi');            
        elseif numberOfFrames == 1
%             disp(':)')
            imwrite(vidMat,'tmp.jpg','Quality',Q);
            vidMat_n = imread('tmp.jpg');
        end
    case 'MPEG-4'
        Q  = param(1); % quality factor
        fs = 30;
        mat2avi('tmp.mp4',vidMat,fs,type,Q);     
        vidMat_n = avi2mat('tmp.mp4');            
    case 'blur'
        SIGMA = param(1);
%         HSIZE = param(2)*ones(1,2);  
%         H     = fspecial('gaussian',HSIZE,SIGMA); % symmetric Gaussian lowpass filter
        for i = 1 : numberOfFrames
%            vidMat_n(:,:,:,i) = imfilter(vidMat(:,:,:,i),H,'replicate');
            vidMat_n(:,:,:,i) = imgaussfilt(vidMat(:,:,:,i),SIGMA);
        end       
    case 'uneven illumination'
        sigma = param(1);
        for i = 1 : numberOfFrames
            vidMat_n(:,:,:,i) = addUnevenIllumination(vidMat(:,:,:,i),sigma);
        end               
end
