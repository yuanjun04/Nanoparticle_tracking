function avitif(video,maximum,count_to,switches,params)
%this takes an input string as the file location, and writes to that
%location a string of .tif files. maximum is a string, y or n for whether
%to convert all frames or just some, count_to is the number to count to
%should maximum == yes. Count_to may take any value should maximum == no

%switches and params are arguments relating to image denoising. Should no
%denoising be required, switches should be a 1D array with 3 elements all
%zero, and params can be anything.

%make sure the maximum is an integer
count_to = round(count_to);

% %read video file
obj = VideoReader(video);
% if strcmp(maximum,'y')
%     vid = read(obj,[1 count_to]);
% else
%     vid = read(obj);
% end

%set max frames
if strcmp(maximum,'y')
    frames = count_to;
else
    frames = obj.NumberOfFrames;
end

%check maximum won't overrun short file
if frames > obj.NumberOfFrames
    frames = obj.NumberOfFrames;
end

%extract video
progressbar('Converting video...');
for x = 1 : frames
    img = read(obj,x);
    imageprocess(img,switches,params);
    imwrite(img,strcat('frame',num2str(x),'.tif'));
    progressbar(x/frames);
end


% %extract video
% progressbar('Converting video')
% for x = 1 : frames
%     imwrite(vid(:,:,:,x),strcat('frame',num2str(x),'.tif'));
%     progressbar(x/frames)
% end 