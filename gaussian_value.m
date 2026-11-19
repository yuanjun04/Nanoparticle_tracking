function output = gaussian_value(mean,stdev,eval_at)

%this calculates the value of a gaussian distribution with characteristics
%mean and stdev, at point eval_at. Mean and stdev are in m, eval_at is in
%nm.

%eval_at_SI = eval_at/100000000000;

output = (1/(stdev*sqrt(2*pi)))*exp(-(((eval_at-mean)^2)/(2*(stdev^2))));