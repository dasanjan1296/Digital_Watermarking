%% Read video into frames
clear all; close all; clc;            % Initialize
vidname = 'Data/video.mpg';           % Video Path
%%% Warning! Any image won't work! Read comments in dwt_embedd for secret
%%% image selection criteria...
secimage = 'Data/secret.png';         % Secret image path
x = 0.1;                                % Embedding Strength
% Increase or decrease the value of x to improve or weaken the embedding
% strength. Higher x values will be more tamper proof, however, will result
% in a larger loss in SNR.

display('Loading Video...')
tic

vidObj = VideoReader(vidname);  % Load video object

% Video parameters
nFrames = vidObj.NumberOfFrames;
vidH = vidObj.Height;
vidW = vidObj.Width;

% Create empty frames
mov(1:nFrames) = struct('cdata',zeros(vidH,vidW,3,'uint8'),'colormap',[]);

% Copy video frames into mov struct
for k = 1:nFrames
    mov(k).cdata = read(vidObj,k);
end
display(['Loaded ' num2str(nFrames) ' frames successfully...']);
toc

%% Frame by Frame Embedding
display('Begin Embedding...')
tic

secret = imread(secimage);
% convert image into binary (0.1 is a predetermined threshold...)
S = im2bw(secret,0.1);
[wmh,wmw] = size(S);
RGB(1:nFrames) = struct('cdata',zeros(vidH,vidW,3,'uint8'),'colormap',[]);
Yorg = zeros(vidH,vidW,nFrames);
Yf_out = zeros(vidH,vidW,nFrames);
for i = 1:nFrames
    YUV = convRGBYUV(mov(i).cdata);
    Yorg(:,:,i) = YUV(:,:,1);   
    % Embedding is done on the Y frame only. In the original paper, the video
    % is converted into grayscale. This makes no sense! Given the motivation
    % for the paper (which is to add a safety feature to movies), converting
    % the movie into grayscale makes no sense at all!...
    Yf_out(:,:,i) = dwt_embedd(Yorg(:,:,i),S,x);
    
    % Convert embedded frame back into RGB (for viewing purposes)
    RGB(i).cdata = uint8(convYUVRGB(cat(3,Yf_out(:,:,i),YUV(:,:,2),YUV(:,:,3)))); 
end

display(['Embedded ' num2str(nFrames) ' frames successfully...']);
toc

%% Frame by Frame Extraction
display('Begin Extracting...')
tic

wMark(1:nFrames) = struct('cdata',zeros(wmh,wmw,1,'uint8'),'colormap',[]);
for i = 1:nFrames
    % Extraction is done using the Y frame of the YUV converted watermarked
    % video. This frame is already saved in the Yf_out variable and
    % therefore used directly. A similar result can be observed by
    % converting RGB variable frames one by one into YUV and taking the Y
    % frame as the watermarked frame. Similarly, the original Y frame is
    % stored in the Yorg variable. Those two are used as inputs to the
    % extractor! Note that the WATERMARK itself is not used at all!
    
    wMark(i).cdata = dwt_extract(Yf_out(:,:,i),Yorg(:,:,i),x,[wmh wmw]);
end

display(['Extracted ' num2str(nFrames) ' frames successfully...']);
toc

%% Result Generation
display('Generating results for each frame...')

% Normalized Correlation - Algorithm from the paper
% This value will always be = 1 when no attack has occured on the
% watermarked image set. If you want to see it degenerating, send an
% attacked version of the video to the dwt_extract and compare results!

NC = ones(1,nFrames);
NCden = sum(sum(S.*S));
for i = 1:nFrames
    NCnum = sum(sum(wMark(i).cdata.*S));
    if (NCden~=NCnum)
        NC(i) = NCnum/NCden;
    end
end


% PSNR
% Only the Y frame of the YUV image is considered. Specific method is not
% defined on the paper. Using the provided algorithm...
MSE = abs((1/(vidH*vidW))*(sum(sum(Yorg - Yf_out))));
PSNR = 10*log((255*255)/MSE);
% Note that PSNR values, in the current configuration, will be high values.
% Higher PSNR suggests a higher imperceptibility. Which means that, if x is
% decreased from 10 to 0.1, PSNR will increase from ~118 to ~165. However,
% when Yf_out is tampered with (attacked), PSNR will be lower because the
% MSE will increase...

%% Output Visualization
% Uncomment the following section to stop generating the video player
% outputs...
h1=implay(mov,vidObj.FrameRate);
h2=implay(RGB,vidObj.FrameRate);
h3=implay(wMark,vidObj.FrameRate);

set(h1.Parent, 'position', [150 100 vidW+10 vidH+10],'Name','Original Video')
set(h2.Parent, 'position', [150+vidW+30 100 vidW+10 vidH+10],'Name','Embedded Video')
set(h3.Parent, 'position', [150+2*vidW+60 100 wmh+10 wmw+10],'Name','Extracted Watermark')

display('Use the movie player to watch the results...')

%% Save Output
% Uncomment the section below if you want to save your entire workspace
% into a new folder! Note that it might be a big memory dump depending on
% your video. It might crash the system... It is best to avoid generating
% the output from the above section if you wish to save the output...
% display('Saving output');
% savpath = 'Save';
% if ~exist(savpath,'file')
%     mkdir(savpath)
% end
% A_ = clock;
% subpath = num2str(round(A_(4)*3600+A_(5)*60+A_(6)));
% fullpath = [savpath '\' subpath];
% save(fullpath);


display('............................................')
display('...........~!Execution Complete!~...........')
