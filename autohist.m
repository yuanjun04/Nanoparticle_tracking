function output = autohist(input)
%this function takes an input array (either a row or a column vector) and
%calculates an appropriate number of bins for the data. It returns these
%bins and the frequency as a two-column array.

%calculates a good number of bins to use
nbins = round((length(input))/10);
if nbins < 10 %histogram with very few bars is useless
    nbins = 10;
end

%measure the range
maximumval = (max(input));
minimumval = (min(input));

%allocate output array
output = zeros(nbins,2);

%make an array of all the bin values
bins = linspace(minimumval,maximumval,nbins);
for j = 1 : nbins
    output(j,1) = bins(j);
end

%loop over each bin and 
for i = 1 : nbins
    unsearched = 1; %allocate loop interrupt
    loops = 1; %new loop counter
    while unsearched == 1;
        [input,unsearched] = searcher(input,output(i),output(i+1));
        loops = loops+1;
        if numel(input) == 0 %add an interupt in case the code runs out of array
            unsearched = 0;
        end
    end
    output(i,2) = loops;
end
        
%check that there are no duplicate bin values, and eliminate them
len = length(output(:,1));
for j = 1 : len-1
    if output(len-j+1,1) == output(len-j,1)
        output(len-j,2) = output(len-j,2)+output(len-j+1,2);
        output(len-j+1,:) = [];
    end
end































end