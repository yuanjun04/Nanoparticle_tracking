function output = columnfixer(first_matrix)

%this function fixes the particle frame numbers in 'first matrix' so that
%they will always reflect the frame in which the particle is, not the one
%it was first detected in.


row = 1;
while row < length(first_matrix(:,1))
    row = row + 1;
    if first_matrix(row,1) == first_matrix(row-1,1)
        first_matrix(row,2) = first_matrix(row-1,2) + 1;
    end
end
output = first_matrix;
end