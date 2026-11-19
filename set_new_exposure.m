function set_new_exposure(new_exposure)

%this function sets a new exposure time for the camera.

%mex set_exposure.cpp -I/usr/local/include/opencv -I/usr/local/include/opencv2 -L/usr/local/lib/ -g -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_objdetect -lopencv_photo -lopencv_ts -lueye_api

check = set_exposure(new_exposure);

if check ~= 1
    errordlg('Error! Setting the new exposure time failed. Check the value you tried to set is within range. This is most likely a software glitch than a user error...','Driver Error Error!');
end
end