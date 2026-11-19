function output = string2framerate(framerate_string,framerate_value)

%this function takes the string from the framerate selection box and turns
%it into a target framerate for the camera

option_string = framerate_string{framerate_value};
output = str2double(option_string(1:end-3));
end