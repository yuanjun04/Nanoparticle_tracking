function still = get_still(settings,loop_count,max_attempts,gain_boost,gain_val,new_exposure,xstart,ystart,width,height)

%this calls the mex function to take a single snapshot. Loop count should
%always be set to zero on the function call, it is incremented by the
%recursive error check. max_attempts is the number of times the runction is
%allowed to call itself before it times out. Settings allows different
%capture options to be set (though this has yet to be implemented.

%single_capture takes a pair of arguments, the first is a binary 1 or 0,
%which switches a flat rate of gain boost on or off. The second is an
%integer taking values between 0 and 100, and is the master hardware gain.
%Between the two, they should give sufficient range of gain values for most
%situations - with gain boost on and gain on 100 there is such a lot of
%noise it's not worth adding any software gain onto the top.

%mex single_capture.cpp -I/usr/local/include/opencv -I/usr/local/include/opencv2 -L/usr/local/lib/ -g -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_objdetect -lopencv_photo -lopencv_ts -lueye_api

%set up all the right files...
% delete('external_still_gain_boost','external_still_gain_val','external_still_new_exposure','external_still_xstart','external_still_ystart','external_still_width','external_still_height');
% 
% fileID = fopen('external_still_gain_boost','w');
% fprintf(fileID,'%s',num2str(gain_boost));
% fclose(fileID);
% 
% fileID = fopen('external_still_gain_val','w');
% fprintf(fileID,'%s',num2str(gain_val));
% fclose(fileID);
% 
% fileID = fopen('external_still_new_exposure','w');
% fprintf(fileID,'%0.6f',new_exposure);%this gives it in exponential form. Needs changing...
% fclose(fileID);
% 
% fileID = fopen('external_still_xstart','w');
% fprintf(fileID,'%s',num2str(xstart));
% fclose(fileID);
% 
% fileID = fopen('external_still_ystart','w');
% fprintf(fileID,'%s',num2str(ystart));
% fclose(fileID);
% 
% fileID = fopen('external_still_width','w');
% fprintf(fileID,'%s',num2str(width));
% fclose(fileID);
% 
% fileID = fopen('external_still_height','w');
% fprintf(fileID,'%s',num2str(height));
% fclose(fileID);
% 
% !sh external_still_compile.sh
% !./external_still.out
% 
open_camera();
try

    a = single_capture(gain_boost,gain_val,new_exposure,xstart,ystart,width,height);
    if (a == 0)
        loop_count = loop_count + 1;
        if (loop_count > max_attempts)
            errordlg('Error! Capture of image failed. Please check camera connection and try again. You may need to restart MatLab.','Capture Error!');
            return
        end
        get_still(settings,loop_count,max_attempts,gain_boost,gain_val,new_exposure,xstart,ystart,width,height);
    end
catch
    if (loop_count > max_attempts)
        errordlg('Error! Capture of image failed. Please check camera connection and try again. You may need to restart MatLab.','Capture Error!');
        return
    else
        loop_count = loop_count + 1;
        get_still(settings,loop_count,max_attempts,gain_boost,gain_val,new_exposure,xstart,ystart,width,height);
    end
end

still = imread('image.jpg');
end