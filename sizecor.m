function output = sizecor(data,pxptch)
%this function takes 'data', which needs to be the output of either
%'accuracy' or 'sterr', more advisably 'accuracy', and using pxptch, the
%pixel pitch, generates an two-column array, containing a list of particle
%hydrodynamic diameters and their corresponding errors, calculated from the
%standard error column in the input data.

%first, make a blank array to hold the output
output = zeros(length(data(:,1)),2);

%make the length in metres
pxptch = pxptch/(10^9);

%then write the new, size-corrected array
for i = 1 : length(data(:,1))
    output(i,1) = data(i,1)*pxptch;
    output(i,2) = data(i,4)*pxptch;
end

end