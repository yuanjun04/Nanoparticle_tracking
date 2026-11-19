function output = track_trim(particles,min_length,framerate)
%this is a simple function that calls 'rad' to calculate the particle track
%statistics, and then cuts out any particle data for particles with track
%lengths shorter than the specified min_length

%first, the particle step length analysis is carried out
data = rad(particles,framerate);

%for the purposes of later simplification, the length of the dataset will
%be written into a variable here
len = length(data(:,1));

%then, the output array is looped over, and any short tracks are weeded
%out.
for i = 1 : len-1
    if data(len-i,3) < min_length
        data(len-i,:) = [];
    end
end

%to get rid of the slightly dodgly (and possibly incomplete) last track
data(end,:) = [];

output = data;
end