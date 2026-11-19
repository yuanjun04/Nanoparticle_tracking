function output = gaussian_plot(data)

%this function takes an input containing several columns, the first 2 of
%which are used. The second one is Standard error used to calculate the width of the
%probability distribution on each particle; this is done by means of
%calculating a gaussian around the centre (given by the first column). The
%sum of these gaussians for all the particles is then taken as the particle
%distribution.

%To get the Standard deviation from the standard error, we need to multiply
%it through by sqrt(n). This is accomplished by using the 3rd column, which
%gives us n.

%firstly, convert all the standrd errors into standard deviations
records = length(data(:,1));
for i = 1 : records
    data(i,2) = data(i,2)*sqrt(data(i,3));
end

%make an output array. In this case, we're contraining a max of 1000nm, min
%of 1
output = zeros(1000,2);

%insert the x-values into output
for i = 1 : length(output(:,1))
    output(i,1) = i*10^(-9);
end


%then populate output
progressbar('Calculating new distribution...');
for i = 1 : length(data(:,1))
    for j = 1 : length(output)
        output(j,2) = output(j,2) + gaussian_value(data(i,1),data(i,2),output(j,1));        
    end
    if rem(i,5) == 0
        progressbar(i/length(data(:,1)));
    end
end
progressbar(1);