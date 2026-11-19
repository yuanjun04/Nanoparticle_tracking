function output = accuracy(particles,min_length,maxdev,framerate)
%this calls sterr (and all subfunctions) to perform track length analysis.
%It also adds the extra variable maxdev, which is the maximum permitted
%percentage of the mean track length that the standard error may be. It is
%recommended to use a value below 100%

%first, sterr is called for the data processing
data = sterr(particles,min_length,framerate);

%for later ease, the length of the dataset is written to a variable here
len = length(data(:,1));

%loop over entire dataset, and remove rows corrensponding to non-conforming
%values.
for i = 1 : (len-1)
    if (data(len-i,4)/data(len-i,1)) > (maxdev/100)
        data(len-i,:) = [];
    end
end

%check output isn't empty
if isempty(data)
    disp('There were no tracks discovered that comply with your settings.')
end

%write output
output = data;

end