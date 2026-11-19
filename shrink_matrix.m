function output = shrink_matrix(input,amount)

%cuts 'amount' off all four sides of 'input'

amount = round(amount);

height = length(input(:,1));
width = length(input(1,:));

output = zeros(height-2*amount,width-2*amount);

for i = 1 : amount
    input(end,:) = [];
    input(:,end) = [];
    input(1,:) = [];
    input(:,1) = [];
end

output = input;