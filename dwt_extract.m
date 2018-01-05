function [wMark] = dwt_extract(wframe,frame,x,wmsize)
% This function extracts the DWT watermark when the watermarked frame and
% the original frame are given as inputs
% SM-201507061952

% Uncomment following if error handling is required
% [~,~,p] = size(wframe);
% if p ~= 1
%     error('wframe dimension needs to be hxwx1');
% end
% [~,~,p] = size(frame);
% if p ~= 1
%     error('frame dimension needs to be hxwx1');
% end

%% Frame manipulation - DWT2
% DWT2 transformation - Level 1
[fLL,fLH,fHL,fHH]=dwt2(frame,'haar');

% DWT2 transformation - Level 2
[fLL21,~,~,fHH21] = dwt2(fLL,'haar');
[fLL22,~,~,fHH22] = dwt2(fHL,'haar');
[fLL23,~,~,fHH23] = dwt2(fLH,'haar');
[fLL24,~,~,fHH24] = dwt2(fHH,'haar');

%% wFrame manipulation - DWT2
% DWT2 transformation - Level 1
[wLL,wLH,wHL,wHH]=dwt2(wframe,'haar');

% DWT2 transformation - Level 2
[wLL21,~,~,wHH21] = dwt2(wLL,'haar');
[wLL22,~,~,wHH22] = dwt2(wHL,'haar');
[wLL23,~,~,wHH23] = dwt2(wLH,'haar');
[wLL24,~,~,wHH24] = dwt2(wHH,'haar');

%% Watermark Regeneration iDWT
[h,w,~] = size(fLL21);
W_ims = zeros(h,w,8);

W_ims(:,:,1) = (wLL21-fLL21)/x;         % Extraction algorithm
W_ims(:,:,2) = (wLL22-fLL22)/x;
W_ims(:,:,3) = (wLL23-fLL23)/x;
W_ims(:,:,4) = (wLL24-fLL24)/x;
W_ims(:,:,5) = (wHH21-fHH21)/x;
W_ims(:,:,6) = (wHH22-fHH22)/x;
W_ims(:,:,7) = (wHH23-fHH23)/x;
W_ims(:,:,8) = (wHH24-fHH24)/x;

W = [];
for i = 1:8
    W = [W reshape(W_ims(:,:,i),1,h*w)];        % Vectorizing
end

% 198x256 are the original dimensions of the input image. The watermarked
% vector is reshaped to match the same shape...

wMark = reshape(round(W),wmsize(1),wmsize(2));  % Rounding W for better accuracy
end

