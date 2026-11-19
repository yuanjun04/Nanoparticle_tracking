function output = exposures()

%this function returns a 3=element column vector containing the maximun,
%minimum, and incremental exposures supported by the camera for any given
%pixel clock and other settings.


%mex query_exposure.cpp -I/usr/local/include/opencv -I/usr/local/include/opencv2 -L/usr/local/lib/ -g -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_objdetect -lopencv_photo -lopencv_ts -lueye_api

output = query_exposure();


end