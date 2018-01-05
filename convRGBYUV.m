function [YUV] = convRGBYUV(RGB)
% This function converts an RGB frame into YUV
% SM-201507061948

% Uncomment the following if error checking is required for input
% [~,~,p] = size(RGB);
% if p ~= 3
%     error('Input must be of size hxwx3');
% end

% Break frames
R = double(RGB(:,:,1));
G = double(RGB(:,:,2));
B = double(RGB(:,:,3));

% Mapping
% Check Reference at: https://en.wikipedia.org/wiki/YUV#Conversion_to.2Ffrom_RGB
Y = 0.299 * R + 0.587 * G + 0.114 * B; 
U = -0.14713 * R - 0.28886 * G + 0.436 * B; 
V = 0.615 * R - 0.51499 * G - 0.10001 * B; 

% Concatanate the matrix back
YUV = cat(3,Y,U,V);

end

