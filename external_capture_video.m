function output = external_capture_video(gain_boost,gain,framerate,frames,exposure,filename,xstart,ystart,width,height,grayscale)

%this is the same (in theory) as ueye_capture_video(), but this calls it as
%a stand-alone program, written in straight C++. This program will then
%exit, releasing the memory in a way that it didn't when written as a mex
%file.

%All the capture parameters are written to serarate files to be read into
%the capture program - there is no way of passing arguments to it straight
%from matlab without being a whole load better at C++ (or using mex files,
%which we're avoiding)

%check that the dimensions are non-zero
if width == 0
    width = 1280;
end
if height == 0
    height = 1024;
end

%delete all text files with settings in:
delete('external_capture_gainboost','external_capture_gain','external_capture_framerate','external_capture_frame_count','external_capture_exposure','external_capture_xdim','external_capture_ydim','external_capture_height','external_capture_width');

%Write all the relevant values to the corresponding text files.
fileID = fopen('external_capture_gainboost','w');
fprintf(fileID,'%s',num2str(gain_boost));
fclose(fileID);

fileID = fopen('external_capture_gain','w');
fprintf(fileID,'%s',num2str(gain));
fclose(fileID);

fileID = fopen('external_capture_framerate','w');
fprintf(fileID,'%s',num2str(framerate));
fclose(fileID);

fileID = fopen('external_capture_frame_count','w');
fprintf(fileID,'%s',num2str(frames));
fclose(fileID);

fileID = fopen('external_capture_exposure','w');
fprintf(fileID,'%s',num2str(exposure));
fclose(fileID);

fileID = fopen('external_capture_gainboost','w');
fprintf(fileID,'%s',num2str(gain_boost));
fclose(fileID);

fileID = fopen('external_capture_xdim','w');
fprintf(fileID,'%s',num2str(xstart));
fclose(fileID);

fileID = fopen('external_capture_ydim','w');
fprintf(fileID,'%s',num2str(ystart));
fclose(fileID);

fileID = fopen('external_capture_width','w');
fprintf(fileID,'%s',num2str(width));
fclose(fileID);

fileID = fopen('external_capture_height','w');
fprintf(fileID,'%s',num2str(height));
fclose(fileID);

%force the camera out of matlab control
!service ueyeusbdrc force-stop
pause(4);
!service ueyeusbdrc start

%run the capture script
!sh external_capture.sh

%then in the case that something in your system prevents the program from
%exiting properly, uncomment the following line. This tells the system to
%kill the most memory-hogging process (almost certainly your software
%framegrabber)
%!ps axo pic --sort -pmem | head -n 2 | tail -n 1 | xargs kill

%read in the framerate the video was just captured at
nCap = str2double(fileread('framerate'));

%and convert it to a useable format
vid = VideoWriter(filename);
vid.FrameRate = nCap;
vid.Quality = 100;
open(vid);
%open(filename);
progressbar('Converting RAW images to video file...');
for i = 0 : frames-1
    img = uint8(imread(strcat('image',num2str(i),'.tif')));
    if grayscale
        img = rgb2gray(img);
    end
    writeVideo(vid,img);
    delete(strcat('image',num2str(i),'.tif'));
    progressbar(i/(frames-1));
end

output = 0;
end







