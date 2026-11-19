function output = string2duration(duration_string,duration_value)

%this function takes the string from the framerate selection box and turns
%it into a target framerate for the camera

option_string = duration_string{duration_value};
output = str2double(option_string(1:end-1));
end