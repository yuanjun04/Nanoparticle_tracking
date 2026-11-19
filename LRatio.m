function lRatios = LRatio(Ij,Ik,m)

%this is a function to calculate the ration of the L-factors for plasmonic
%scattering, given the two intensities from the distribution, Ij, and Ik,
%and the complex refractive index, m. Note, Re(m)>1, and |m|>1.

%Note, there are 4 values that lRatio could take, given the 4 combinations
%of parity. lRatios is therefore a 4-element array, containing all 4
%values.

%define our constants
c = 2.98E8;
n = 2*sqrt((2*pi)/c);

%then calculate the ratio for all 4 parity options
lRatios = zeros(4,1);

%both positive
top = (abs(m^2 - 1) - n*sqrt(Ik))*sqrt(Ij);
bottom = (abs(m^2 - 1) - n*sqrt(Ij))*sqrt(Ik);
lRatios(1) = top/bottom;

%top positive, bottom negative
top = ((m^2 - 1) - n*sqrt(Ik))*sqrt(Ij);
bottom = (-(m^2 - 1) - n*sqrt(Ij))*sqrt(Ik);
lRatios(2) = top/bottom;

%top negative, bottom positive
top = (-(m^2 - 1) - n*sqrt(Ik))*sqrt(Ij);
bottom = ((m^2 - 1) - n*sqrt(Ij))*sqrt(Ik);
lRatios(3) = top/bottom;

%both negative
top = (-(m^2 - 1) - n*sqrt(Ik))*sqrt(Ij);
bottom = (-(m^2 - 1) - n*sqrt(Ij))*sqrt(Ik);
lRatios(4) = top/bottom;
