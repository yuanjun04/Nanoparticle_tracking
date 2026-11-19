function [returned,output] = searcher(input,min,max)
%returns a 1 if it finds a value between min and max in the input array,
%zero if not. When it finds a match, it makes it takes it out the array so
%it won't be found again

output = 0;
loops = 1; %new loop counter
searching = 1; %new loop parameter

if numel(input) ~= 0;
    while searching
        if input(loops) >= min
            if input(loops) <= max
                input(loops) = [];
                output = 1;
                searching = 0;
            end
        end
        if loops == length(input)
            searching = 0;
        end
        loops = loops+1;
    end
end
returned = input;
end