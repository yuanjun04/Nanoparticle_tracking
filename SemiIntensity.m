function [Ij,Ik] = SemiIntensity(nDist)

%this function gives the two salient intensity values of an intensity
%distribution passed as nDist. nDist is a list of intensities of a particle
%in an arbitrary order. The distribution is expected to be either normal
%(in which case Ij=Ik), or lognormal (in which case Ij<Ik).

%first, take the average
mu = mean(nDist(:));

%calculate histogram data
[counts,centres] = hist(nDist,500);

%put this histogram data in a form that lognormal can take...
hist_data = zeros(length(counts),2);
for i = 1 : length(counts)
    hist_data(i,1) = centres(i);
    hist_data(i,2) = counts(i);
end

%call Kevin's lognormal algorithm
lognormal_data = lognormal(hist_data);

%the salient part of lognormal_data is the first element, the lognormal
%mean (the peak). This is Ij
Ij = lognormal_data(1);

%then we use the difference between Ij and mu to calculate Ik. If mu is
%smaller than Ij, it is assumed that the particle is spherical. This may
%change in future releases.
if Ij > mu
    Ik = Ij;
else
    Ik = mu + (mu - Ij);
end


