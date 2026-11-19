function output = zoom_params(hObject,handles)

%function called to write all the capture parameters to files to allow
%unconnected childs without shared handles structures to access the
%camera.

%mono or not?
fid_mono = fopen('mono.dat','w');
fprintf(fid_mono,'%u',get(handles.mono_button,'value'));
fclose(fid_mono);

%camera gain
fid_gain = fopen('gain.dat','w');
fprintf(fid_gain,'%u',get(handles.gain_slider,'value'));
fclose(fid_gain);

%gainboost
fid_gainboost = fopen('gainboost.dat','w');
fprintf(fid_gainboost,'%u',get(handles.gainboost,'value'));
fclose(fid_gainboost);

%exposure
fid_exposure = fopen('exposure.dat','w');
fprintf(fid_exposure,'%u',get(handles.exposure,'value'));
fclose(fid_exposure);

%roi limits?
fid_roi_on = fopen('roi_on.dat','w');
fprintf(fid_roi_on,'%u',get(handles.limit_roi_checkbox,'value'));
fclose(fid_roi_on);

%roi left
fid_left = fopen('roi_left.dat','w');
fprintf(fid_left,'%s',get(handles.left_roi_limit,'string'));
fclose(fid_left);

%roi right
fid_right = fopen('roi_right.dat','w');
fprintf(fid_right,'%s',get(handles.right_roi_limit,'string'));
fclose(fid_right);

%roi top
fid_top = fopen('roi_top.dat','w');
fprintf(fid_top,'%s',get(handles.top_roi_limit,'string'));
fclose(fid_top);

%roi bottom
fid_bottom = fopen('roi_bottom.dat','w');
fprintf(fid_bottom,'%s',get(handles.bottom_roi_limit,'string'));
fclose(fid_bottom);

output = 1;
end