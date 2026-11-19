function gaussian_matrix = add_gaussian(matrix,radius,xpos1,ypos,mean,stdev)

%Matrix is the frame of the particle matrix that needs a normalised gaussian peak
%adding of specified radius at position (xpos,ypos). The values of mean and
%stdev are for the gaussian. Mean should usually be zero (the gaussian is
%centered on the location of the particle). Stdev should be a sensible
%number, about a factor of 5 smaller than the radius. The selection of
%stdev may be automated in later revisions.


%first determine the co-ordinates to be iterated from
%top_left = [xpos-radius ypos-radius];
xpos = round(ypos + radius);
ypos = round(xpos1 + radius);

if xpos -radius == 0
    xpos = xpos + 1;
end
if ypos - radius == 0
    ypos = ypos + 1;
end

%then call three_gauss to generate the full gaussian surface to be added
gaussian = three_gauss(radius,mean,stdev);
gaussian = gaussian * 100;

%additively add the new gaussian surface to the pre-existing matrix
for i = xpos-radius : xpos+radius-1
    for j = ypos-radius : ypos+radius-1
        matrix(i,j) = matrix(i,j)+gaussian((i+1)-(xpos-radius),(j+1)-(ypos-radius));
    end
end

%and return the final value
gaussian_matrix = matrix;
end