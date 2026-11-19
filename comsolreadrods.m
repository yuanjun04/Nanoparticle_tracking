rodints={};
for i = 0:2:90
    rodints{end+1} = zeros(35069,4);
    rodints{end} = csvread(strcat(num2str(i),'deg.csv'));
end

allrodints = [];
for i = 1:length(rodints)
    allrodints(end+1:end+length(rodints{i}(:,4))) = rodints{i}(:,4);
end