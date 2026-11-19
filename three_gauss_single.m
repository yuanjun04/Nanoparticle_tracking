function array = three_gauss_single(radius,mean,stdev)

%Firstly, calculate the 1D gaussian for the given size array
gaussian = calculate_gaussian_single(2*radius,mean,stdev);

%then generate a blank dummy square matrix of the right dimensions
blocks = zeros(2*radius,2*radius);

%and iterate over the entire matrix generating a gaussian ridge
for i = 1 : 2*radius
    for j = 1 : 2*radius
        blocks(i,j) = blocks(i,j)+gaussian(j);
    end
end

%and iterate over again, this time the other way, and combine the gaussians
%multiplicatively
for i = 1 : 2*radius
    for j = 1 : 2* radius
        blocks(i,j) = blocks(i,j)*gaussian(i);
    end
end
%this gives a normalised gaussian, since both the original gaussians were
%also normalised.


%then the final matrix can be returned to the calling function. Bazinga.
array = blocks;
end

%note that this always produces a gaussian of the same radius, but stdev
%actually acts to modify the volume of the gaussian. Predict that an stdev
%of 1 should generate a normalised gaussian.
