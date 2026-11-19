function output = update_preview(hObject,eventdata,handles)

%this function should be called after modification of any capture
%parameters in the GUI

%get capture pearameters from GUI
gain_boost = get(handles.gainboost,'value');
gain_val = round(get(handles.gain_slider,'value'));
exposure_val = exposures();
old_exposure = get(handles.exposure,'Value');
if and(old_exposure > exposure_val(1), old_exposure < exposure_val(2))
    set(handles.exposure,'Min',exposure_val(1));
    set(handles.exposure,'Max',exposure_val(2));
    set(handles.exposure,'SliderStep',[exposure_val(3) exposure_val(3)]);
else
    set(handles.exposure,'Value',exposure_val(1));
    set(handles.exposure,'Min',exposure_val(1));
    set(handles.exposure,'Max',exposure_val(2));
    set(handles.exposure,'SliderStep',[exposure_val(3) exposure_val(3)]);
end
exposure_new = get(handles.exposure,'value');

%get area of interest data
if get(handles.limit_roi_checkbox,'value')
    if strcmp('Left',get(handles.left_roi_limit,'string'))
        output = 1;
        return
    else
        leftaoi = round(str2double(get(handles.left_roi_limit,'string')));
    end
    if strcmp('Right',get(handles.right_roi_limit,'string'))
        output = 1;
        return
    else
        rightaoi = round(str2double(get(handles.right_roi_limit,'string')));
    end
    if strcmp('Top',get(handles.top_roi_limit,'string'))
        output = 1;
        return
    else
        topaoi = round(str2double(get(handles.top_roi_limit,'string')));
    end
    if strcmp('Bottom',get(handles.bottom_roi_limit,'string'))
        output = 1;
        return
    else
        bottomaoi = round(str2double(get(handles.bottom_roi_limit,'string')));
    end
    xstart = leftaoi;
    ystart = topaoi;
    width = abs(leftaoi-rightaoi);
    height = abs(topaoi-bottomaoi);
    %and validate the values to ensure they're compatible with the camera
    valid = validate_aoi(xstart,ystart,width,height);
    xstart = valid{1};
    ystart = valid{2};
    width = valid{3};
    height = valid{4};
    
else
    xstart = 1;
    ystart = 1;
    width = 0;
    height = 0;
end

%capture frame from camera
frame = get_still(1,0,3,gain_boost,gain_val,exposure_new,xstart,ystart,width,height);

%select colour
if ~get(handles.colour_button,'value')
    frame = rgb2gray(frame);
end

%select axes
axes(handles.camera_preview);

%display it
imshow(frame)

%better make it do something trivial...
output = 1;

%update handles structure
guidata(hObject,handles);
end