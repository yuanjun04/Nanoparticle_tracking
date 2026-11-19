function output = draw_square(matrix,centre,radius,value)

%this function adds a particular value to every cell in a submatrix
%centered at 'centre', and with sides of length twice the 'radius'. Side
%length is defined such that it is only possible to get integer numbers
%for the number of radial matrix cells to the border of the submatrical
%region. Centre is a 2-element array, containing an x-y tuple. Centre gives
%the co-ordinates in the field of view, not the visible region. Matrix is
%the extended visible region, not the FoV

%The radius is rounded to the nearest integer to ensure only integer matrix
%indices are called.
radius = round(radius);

%Then the top left (lowest indices) corner of the square to be 'drawn' is
%found.
top_left = zeros(2);
top_left(1) = centre(1);
top_left(2) = centre(2);

%Finally, the square defined is iterated over in lines and columns until
%every value within the square has had 'value' added to it.
for i = top_left(2) : top_left(2)+2*radius
    for j = top_left(1) : top_left(1)+2*radius
        matrix(i,j) = matrix(i,j)+value;
    end
end
output = matrix;
end