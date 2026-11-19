function analyse
%runs a full analysis of a video, and deletes the scratch files afterwards
avitif('file.avi') %load and convert the video






























for x = 1 : frames
    delete(strcat('frame',num2str(x),'.tif'));


%finish by deleting all the videos
end