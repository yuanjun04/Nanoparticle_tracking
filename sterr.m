function output = sterr(particles,min_length,framerate)
%this function calls track_trim to generate an output, and then adds a
%fourth column onto the output that contains the standard error in each
%mean step length calculated.

%call track_trim
data = track_trim(particles,min_length,framerate);

%make a new empty array to copy all the data into
new_data = zeros(length(data(:,1)),4);

%loop over every row in the original table, and copy the values across
for i = 1 : length(data(:,1))
    new_data(i,1) = data(i,1);
    new_data(i,2) = data(i,2);
    new_data(i,3) = data(i,3);
    new_data(i,4) = data(i,2)/sqrt(data(i,3)); %not forgetting to do the standard error calculation...
end

%and set the output variable equal to the new data table
output = new_data;

end