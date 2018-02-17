function [distortedImage, mask] = addUnevenIllumination(Image,sigma)

% Generation of gaussian mask
x_0 = round(size(Image,2)/2); y_0 = round(size(Image,1)/2);
[X, Y] = meshgrid(1:size(Image,2), 1:size(Image,1));
%sig_x = 0.00005; sig_y = 0.00005;
Q_m = 1;

mask = Q_m*exp(-(sigma*(X - x_0).^2 + sigma*(Y - y_0).^2));

distortedImage = im2uint8(im2double(Image) .* mask);