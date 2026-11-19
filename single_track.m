function [input,output] = single_track(input,startframe,startindex)
%this function will track a single particle through an array given an
%input, and a starting position in this for a particle. Because it modifies
%the data in the array sent to it, it needs to return the modified cell
%array

%does this help?
input = input;
output = zeros(0,4); %just in case of an early return

%check the start position is valid
if size(input{startframe}) == [0 6] %catch empty frames...
    return
end
if size(input{startframe}(:,1)) < startindex
    return
end
disp(size(input{startframe}));
if input{startframe}(startindex,6) == -1
    %disp('Warning! This is not a trackable particle! It will return a blank array entry');
end

%create blank column vectors for the frame number and
%position vectors
frameno = [];
xpos = [];
ypos = [];
intensity = [];


%then search for the tracks between frames
frame = startframe-1;
index = startindex;
tracking = 1;
while tracking ~= 0
    frame = frame+1;
    if size(input{frame}) == [0 6] %make sure frames with no particles are skipped
        return
    end
    if input{frame}(index,6) == -1
        tracking = 0; %end tracking when particle disappears
    end
    next_pos = input{frame}(index,6);
    input{frame}(index,6) = -1; %switch it to -1 once it's been followed
    frameno(end+1) = frame;
    xpos(end+1) = input{frame}(index,1);
    ypos(end+1) = input{frame}(index,2);
    intensity(end+1) = input{frame}(index,3);
    index = next_pos;
end

%and finally get the end array put together
output = zeros(length(frameno),4);
for i = 1 : length(frameno)
    output(i,1) = frameno(i);
    output(i,2) = xpos(i);
    output(i,3) = ypos(i);
    output(i,4) = intensity(i);
end

end
