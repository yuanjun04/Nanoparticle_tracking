function output = check_detection(hObject,handles)

%this reads the values of detection parameters and then looks at the image
%to determine the particle locations. These are then returned so they can
%be plotted on top of the preview frame.

w = round(get(handles.glob_slide,'value'));
cutoff = get(handles.cutoff_slide,'value');
pth = get(handles.thresh_slide,'value');
img = image_cleanup(hObject,handles);

%the 20 is the maximum detect loops, which stops the position refinement
%contuing indefinitely in the event that refinements suggest there isn't a
%particle there within the threshold specified...
output = check_particles(w,cutoff,pth,20,img);