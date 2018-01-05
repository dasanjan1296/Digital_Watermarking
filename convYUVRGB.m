function [RGB] = convYUVRGB(YUV)
% This function converts an YUV frame into RGB
% SM-201507061952

% Uncomment the following if error checking is required for input
% [~,~,p] = size(YUV);
% if p ~= 3
%     error('Input must be of size hxwx3');
% end

% Break frames
Y = YUV(:,:,1);
U = YUV(:,:,2);
V = YUV(:,:,3);

% Mapping
% Check Reference at: https://en.wikipedia.org/wiki/YUV#Conversion_to.2Ffrom_RGB
R = Y               +  1.13983 * V; 
G = Y - 0.39465 * U -  0.58060 * V; 
B = Y + 2.03211 * U               ; 

% Concatanate the matrix back
RGB = cat(3,R,G,B);

end

