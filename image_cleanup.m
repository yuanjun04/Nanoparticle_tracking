function output = image_cleanup(hObject,handles)

%this function reads the selected video frame and applies all the necessary
%image cleanup operations as specified in the left-hand section of the GUI.
%It is intelligent, and can tell whether it should red an AVI or a stack of
%tiff images with an .ids file.

%determine what it should be reading.
vid_path = get(handles.pathbox,'string');
if strcmp(vid_path(end-2:end),'avi')
    type = 'avi';
elseif strcmp(vid_path(end-2:end),'ids')
    type = 'ids';
else
    errordlg('The filetype you are attempting to read was not recognised!');
    return
end


if strcmp(type,'avi')
    %read video container
    obj = VideoReader(vid_path);

    % %set bounds on slider
    % set(handles.position,'min',0);
    % set(handles.position,'max',obj.NumberOfFrames - 1);

    %read new slider position
    frame = get(handles.position,'value');

    %and read that frame of video file
    img = read(obj,frame);
else
    %start parsing the separate files
    newdir = vid_path;
    while ~strcmp(newdir(end),'/')
        newdir = newdir(1:end-1);
    end
    currentdir = pwd;
    cd(newdir);
    %disp(newdir);
    searchfiles = dir('image*');
    cd(currentdir);
    framecount = length(searchfiles);
    frame = round(get(handles.position,'value'));
    if frame > framecount
        disp(frame);
        disp(framecount);
        errordlg('Something went wrong reading the frame, index out of range');
        return
    end

    img = imread(strcat(newdir,'image',num2str(frame-1),'.tif'));

    
    
end

%make sure the image is grayscale
try
    img = rgb2gray(img);
catch
end

%add any gain
if get(handles.screen_gain_box,'value')
    %add some gain
    gainvalue = get(handles.screen_gain_slide,'value');
    img = img * gainvalue;
    for i = 1 : length (img(:))
        if img(i) > 255 %and make sure the max brightness isn't surpassed
            img(i) = 255;
        end
    end    
end

%disc tophat filter
if get(handles.disc,'value')
    radius = round(get(handles.background_disk,'value'));
    se = strel('disk',radius);
    img = imtophat(img,se);
end


disp('1');
%denoise the image
if get(handles.denoise_box,'value')
    img = img - get(handles.background,'value');
    img = img*(255/get(handles.background,'value'));
end

if get(handles.blur_box,'value')
    sigma = get(handles.blur,'value');

    %# Create the gaussian filter with hsize = [5 5]
    G = fspecial('gaussian',[round(sigma/2) round(sigma/2)],sigma);
    %# Filter it
    img = imfilter(img,G,'same');
end


disp('3');
output = img;
disp('2');
%and update handles structure
guidata(hObject,handles);

disp('4');