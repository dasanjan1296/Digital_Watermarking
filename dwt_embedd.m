function [emFrame] = dwt_embedd(frame,secret,x)
% This function embedds an input frame with the secret image using DWT
% SM-201507061952

% Uncomment following if error handling is required
% [~,~,p] = size(frame);
% if p ~= 1
%     error('Frame dimension needs to be hxwx1');
% end
% [~,~,p] = size(secret);
% if p ~= 1
%     error('Frame dimension needs to be hxwx1');
% end

%% Frame manipulation - DWT2
% DWT2 transformation - Level 1
[LL,LH,HL,HH]=dwt2(frame,'haar');

% DWT2 transformation - Level 2
[LL21,LH21,HL21,HH21] = dwt2(LL,'haar');
[LL22,LH22,HL22,HH22] = dwt2(HL,'haar');
[LL23,LH23,HL23,HH23] = dwt2(LH,'haar');
[LL24,LH24,HL24,HH24] = dwt2(HH,'haar');

[h,w,~] = size(LL21);
%% Secret Image Manipulation
% For the given video, size(LL21) = 72x88... The secret image should be
% broken into 8 blocks of this size. Therefore, the chosen secret image is 
% of size 99x512 (This is 8 times the LL21 frame size!). This must be
% changed according to the video size. For example, in the paper, the
% chosen size is said to be 32x32. However, finding a video of this exact
% matching dimension is difficult...

SS = reshape(secret,1,numel(secret));   % Vectorize the secret image
blk_size = h*w;                         % Each block size
init = 0;                               % array location pointer

W_ims = zeros(h,w,8);                   % Definie

for i = 1:8
    W_ims(:,:,i) = reshape(SS(init+1:i*blk_size),h,w);  % Allocation
    init = i*blk_size;                  % Change array pointer
end

newLL21 = LL21 + x*W_ims(:,:,1);
newLL22 = LL22 + x*W_ims(:,:,2);
newLL23 = LL23 + x*W_ims(:,:,3);
newLL24 = LL24 + x*W_ims(:,:,4);
newHH21 = HH21 + x*W_ims(:,:,5);
newHH22 = HH22 + x*W_ims(:,:,6);
newHH23 = HH23 + x*W_ims(:,:,7);
newHH24 = HH24 + x*W_ims(:,:,8);

%% Frame Regeneration iDWT
newLL = idwt2(newLL21,LH21,HL21,newHH21,'haar');
newHL = idwt2(newLL22,LH22,HL22,newHH22,'haar');
newLH = idwt2(newLL23,LH23,HL23,newHH23,'haar');
newHH = idwt2(newLL24,LH24,HL24,newHH24,'haar');

emFrame = idwt2(newLL,newLH,newHL,newHH,'haar');
end

