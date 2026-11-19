function frame = get_snapshot(settings,loop_count,max_attempts,gain_boost,gain_val,new_exposure,xstart,ystart,width,height)

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

mex snapshot.cpp -I/usr/local/include/opencv -I/usr/local/include/opencv2 -L/usr/local/lib/ -g -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_objdetect -lopencv_photo -lopencv_ts -lueye_api

try

    a = snapshot(gain_boost,gain_val,new_exposure,xstart,ystart,width,height);
    if (a == 0)
        loop_count = loop_count + 1;
        if (loop_count > max_attempts)
            errordlg('Error! Capture of image failed. Please check camera connection and try again. You may need to restart MatLab.','Capture Error!');
            return
        end
        get_snapshot(settings,loop_count,max_attempts);
    end
catch
    if (loop_count > max_attempts)
        errordlg('Error! Capture of image failed. Please check camera connection and try again. You may need to restart MatLab.','Capture Error!');
        return
    else
        loop_count = loop_count + 1;
        get_snapshot(settings,loop_count,max_attempts);
    end
end

frame = imread('image.tif');

end