function output = remove_invalid(input)

%this searches through an array, input, and removes any rows which contain
%either inf of NaN in them


for i = 1 : length(input(1,:)) %columns
    for j = 1 : length(input(:,1))-1 %rows
        if or(or(isnan(input(j,i)), isinf(input(j,i))),input(j,i) == 0)
            input(j,:)=[];
            input = remove_invalid(input);
            output = input;
            return
        end
    end
end
output = input;


% rows = length(input(:,1));
% columns = length(input(1,:));
% k = 0;
% l = 0;
% for i = 1 : rows
%     k = k + 1;
%     for j = 1 : columns
%         l = l + 1;
%         if or(isnan(input(k,l)),isinf(input(k,l)))
%             input(k,:)=[];
%             k = k - 1;
%         end
%     end
% end
            
            