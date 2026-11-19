function output = stokes_einstein(temp,x,viscosity)
%applies stokes-einstein relationship to determine mean hydrodynamic radius
boltzmann = 1.38*(10^(-23));
% output = ((boltzmann*temp)/(3*pi*viscosity*x^2));
output = ((boltzmann*temp)/(6*pi*viscosity*x)); % this is correct
%output = ((boltzmann*temp)/(6*pi*viscosity*((x^2)/4)));
end