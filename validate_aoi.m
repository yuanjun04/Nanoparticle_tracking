function output= validate_aoi(xstart,ystart,width,height)

%validates the settings for aoi against the relevant uEye camera details
%and modifies them where necessary.

if rem(xstart,2) ~= 0
    xstart = xstart + 1;
end
if rem(ystart,2) ~= 0
    ystart = ystart + 1;
end
if rem(height,2) ~= 0
    height = height + 1;
end
if height < 4
    height = 4;
end
if rem(width,4) ~= 0
    while rem(width,4) ~= 0
        width = width + 1;
    end
end
if width < 16
    width = 16;
end
output = cell(4,1);
output{1} = xstart;
output{2} = ystart;
output{3} = width;
output{4} = height;