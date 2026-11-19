function output = ueye_capture_video_SSD(gain_boost,gain,framerate,frames,exposure,filename,xstart,ystart,width,height,grayscale)

%mex video_capture.cpp -v -I/usr/include/gtk-2.0/ -I/usr/include/atk-1.0/ -I/usr/include/gdk-pixbuf-2.0/ -I/usr/lib/x86_64-linux-gnu/gtk-2.0/include/ -I/usr/include/pango-1.0/ -I/usr/include/pango-1.0/pango/ -I/usr/include/cairo/ -I/usr/lib/x86_64-linux-gnu/glib-2.0/include/ -I/usr/include/glib-2.0/ -I/usr/local/include/opencv -I/usr/local/include/opencv2 -L/usr/local/lib/ -g -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_objdetect -lopencv_photo -lopencv_ts -lueye_api
%the mex compiler cannot cope with compiling with gtk for an external UI.
%Therefore, use the custom compiler script instead:
!sh progress_compile_SSD.sh

%passing strings to mexfiles is a pain, but the mexfile needs the filename
%and save location because the final file is written by the mexfile rather
%than subsequent matlab code. The same goes for the grayscale parameter (I
%can't be bothered to make it pass nicely to mex, so I'll pass it in a file
%as well. I can't be bothered to work out how to pass more than one
%variable in a single file, so the grayscale parameter will go in its own
%file.

%spaces aren't passed properly to C++
for i = 1 : length(filename)
    if strcmp(filename(i),' ')
        errordlg('You cannot save to paths which have spaces in them yet. This is due to an incompatibility issue between the handling of strings between matlab and C++, and directory handling on linux and matlab');
        return
    end
end

%the filename is unimportant, but the directory is.
newdir = filename(1:end-4);
while ~strcmp(newdir(end),'/')
    newdir = newdir(1:end-1);
end

filenamefid = fopen('SSD_Filename.mdf','w');
fprintf(filenamefid,'%s',newdir);
fclose(filenamefid);

grayscalefid = fopen('SSD_Grayscale.mdf','w');
fprintf(grayscalefid,'%u',grayscale);
fclose(grayscalefid);

%the return of this function (if successful) is the exact framerate of the
%video that was captured. This is used to construct an avi video file from
%the images.
nCap = video_capture_SSD(gain_boost,gain,framerate,frames,exposure,xstart,ystart,width,height);
if nCap == -1
    errordlg('Capture failed for some annoying and unknown reason, quite possibly because matlab encountered a segfault.','Capture error!');
    output = -1;
    return
end

%and move the params file with the framerate in it into the target
%directory
frameratefid = fopen(strcat(newdir,'capturedata.mdf'),'w');
fprintf(frameratefid,'%u',nCap);
fclose(frameratefid);


% %clear mex;
% if grayscale
%     vid = VideoWriter(filename,'Grayscale AVI');
% else
%     vid = VideoWriter(filename,'Uncompressed AVI');
%     %vid.Quality = 100;
% end
% vid.FrameRate = nCap;
% 
% open(vid);
% 
% %open(filename);
% progressbar('Converting RAW images to video file...');
% for i = 0 : frames-1
%     img = uint8(imread(strcat('image',num2str(i),'.tif')));
%     if grayscale
%         img = rgb2gray(img);
%     end
%     writeVideo(vid,img);
%     delete(strcat('image',num2str(i),'.tif'));
%     progressbar(i/(frames-1));
% end
% close(vid);
 output = 0;
 end
