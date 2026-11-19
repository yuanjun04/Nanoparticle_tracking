function output = matrix_reorientate(matrices,first_dimension)

%this pulls the second two dimensions from a 3-d matrix and puts them into
%their own 2d matrix. Matrices is a 3d matrix, and first_dimension is the
%number of the row the 2d matrix needs to be pulled from.
sub_matrix = zeros(length(matrices(1,:,1)),length(matrices(1,1,:)),'single');
for i = 1 : length(matrices(1,:,1))
    for j = 1 : length(matrices(1,1,:))
        sub_matrix(i,j) = matrices(first_dimension,i,j);
    end
end
output = sub_matrix;
end