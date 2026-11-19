function img = imageprocess(img,switches,params)

%this function performs all the image processing for the analysis software.
%img is the raw video frame to be processed, switches is an array
%containing boolean values corresponding to:

%intensify
%disc filter
%blur

%in that order. params is a similar 1D array containing the corresponding
%parameters for those three filters.

intensify_switch = switches(1);
disc_switch = switches(2);
blur_switch = switches(3);



if disc_switch == 1
    disc_param = params(2);
    radius = round(disc_param);
    se = strel('disk',radius);
    img = imtophat(img,se);
end

if intensify_switch == 1
    intensify_param = params(1);
    img = img - intensify_param;
    img = img*(255/intensify_param);
end

if blur_switch == 1
    blur_param = params(3);
    sigma = blur_param;
    G = fspecial('gaussian',[round(sigma/2) round(sigma/2)],sigma);
    img = imfilter(img,G,'same');
end

end