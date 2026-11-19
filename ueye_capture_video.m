function output = ueye_capture_video(gain_boost,gain,framerate,frames,exposure,filename,xstart,ystart,width,height,grayscale)

%mex video_capture.cpp -v -I/usr/include/gtk-2.0/ -I/usr/include/atk-1.0/ -I/usr/include/gdk-pixbuf-2.0/ -I/usr/lib/x86_64-linux-gnu/gtk-2.0/include/ -I/usr/include/pango-1.0/ -I/usr/include/pango-1.0/pango/ -I/usr/include/cairo/ -I/usr/lib/x86_64-linux-gnu/glib-2.0/include/ -I/usr/include/glib-2.0/ -I/usr/local/include/opencv -I/usr/local/include/opencv2 -L/usr/local/lib/ -g -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_objdetect -lopencv_photo -lopencv_ts -lueye_api
%the mex compiler cannot cope with compiling with gtk for an external UI.
%Therefore, use the custom compiler script instead:
!sh progress_compile.sh


%the return of this function (if successful) is the exact framerate of the
%video that was captured. This is used to construct an avi video file from
%the images.
nCap = video_capture(gain_boost,gain,framerate,frames,exposure,xstart,ystart,width,height);
if nCap == -1
    errordlg('Capture failed for some annoying and unknown reason, quite possibly because matlab encountered a segfault.','Capture error!');
    output = -1;
    return
end

%clear mex;
if grayscale
    vid = VideoWriter(filename,'Grayscale AVI');
else
    vid = VideoWriter(filename,'Uncompressed AVI');
    %vid.Quality = 100;
end
vid.FrameRate = nCap;

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
close(vid);
 output = 0;
 end
