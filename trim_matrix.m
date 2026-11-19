function small_matrix = trim_matrix(matrix,amount)
%This function trims 'amount' many cells off each of the four sides of a 2D
%matrix.

%First, a blank matrix the size of the output is generated
small_matrix = zeros((length(matrix(1,:))-2*amount),(length(matrix(:,1))-2*amount));

%Then, the top corner of the desired matrix is found.
top_left = [amount amount];

k = 1;
l = 1;
for i = top_left(1) : (length(matrix(1)))-2*amount
    for j = top_left(2) : (length(matrix(2)))-2*amount
        small_matrix(k,l) = matrix(i,j);
        l = l+1;
    end
    k = k+1;
end
end