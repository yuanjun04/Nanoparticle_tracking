G_Data = load('sample3.txt');
time = G_Data(:,1);
Ax = G_Data(:,2);
Ay = G_Data(:,3);
Az = G_Data(:,4);

%make a cell to hold your arrays
outarrays = {};

%initialise a sub-array counter
subarray = 1;

%loop over all datapoints
for datapoint = 1 : length (Ax)
    outarrays{datapoint} = [];
    if Ax(datapoint) < 0.1
        outarrays{subarray}(end+1) = Ax(datapoint);
    else
        %move on to next sub-array
        subarray = subarray + 1;
    end
    datapoint = datapoint + 1;
end

cumulative_time = 0;
for subarray = 1 : n - 1
    cumulative_time = cumulative_time + length(outarrays{subarray});
end
disp(n);
disp(length(outarrays{1}));
plot(time(cumulative_time : cumulative_time + length(outarrays{n})),outarrays{n});