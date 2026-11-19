obj = VideoReader('/media/sam/Data Backup/New Lab Testing/100nm BnW0.avi');
vid = VideoWriter('testVid.avi');
vid.FrameRate = obj.FrameRate;
vid.Quality = 100;
open(vid);
for i = 1 : obj.NumberOfFrames
    frame = read(obj,i);
    if size(frame) ~= [1024 1280 3]
        disp('Wrong input ',i);
    end
    frame = rgb2gray(frame);
    if size(frame) ~= [1024 1280]
        disp('wrong conversion ',i);
    end
    writeVideo(vid,frame);
end
close(vid);