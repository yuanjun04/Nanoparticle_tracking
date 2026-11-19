function gaussian = calculate_gaussian(points,mean,stdev)
%function to be called by draw_gaussian to calculate the values of the
%normalised gaussian curves to be used.

%an array called 'x' is generated such that the gaussian has a decent
%chance to decay before being cut off, and so that the points of the
%generated gaussian are evenly distributed through space.
x = linspace((mean-5*stdev),(mean+5*stdev),points);

%Then the gaussian is generated, simples! :)
gaussian = (1/(stdev*sqrt(2*pi)))*exp((-(x-mean).^2)/(2*stdev^2));
end