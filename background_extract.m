function bgimage = background_extract(path,stub,startno,endno,extension)
%produces a background from an image stack using a simple averaging method.

%work out size of images
testframe = imread(strcat(path,stub,num2str(startno),extension));

%and make an empty array of that size to hold the background
bgimage = zeros(size(testframe,1),size(testframe,2));

%add each contribution to the background as a float
for iframe = startno : endno
    frame = double(imread(strcat(path,stub,num2str(iframe),extension)));
    bgimage = bgimage + (frame/(endno-startno));
end

%make sure it's something that's readable as a grayscale image to turn them
%back into integers
bgimage = uint8(bgimage);
end

