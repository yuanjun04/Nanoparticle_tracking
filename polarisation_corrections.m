function [L1,L2] = polarisation_corrections(a,b)

%This function takes the semi-axes of a spheroidal particle, a, and b
%(b=c), and calculates the corrections to the polarisation equation
%(E = E_0 - 4*Pi*L*P). L2=L3.

L1 = 1/(1+((2*a)/b));
L2 = 1 - L1;

end