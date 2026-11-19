function output = eccentricity(input,m,r)

%this takes an input array with 6 columns. The first is the particle
%number, which identifies the particle. The 6th is the other salient one,
%which is the 0 order intensity moment associated with that particle in
%that frame. Particles have multiple intensity moments associated with
%them. Switch is 0 for looking at the sample as an ensemble, and 1 for
%looking at individual particles. 0 gives much smaller error if the sample
%is expected to contain identically-shaped particles, while 1 allows
%distinction between different shapes in the sample sample. m is the
%complex refractive index of the particles. r is the mean hydrodynamic radius of
%the particle.

%output is an array with 2 columns for the case of an ensemble analysis,
%with the four possible a,b pairs. Hopefully, only one will be non-zero.

%if the switches is set to 1 and all particles are considered
%independently, output becomes a cell array with the same information for
%each particle as a separate array in the cell

%remove particles with a single entry - cannot assume distribution from single value.
nParts = input(end,1);
for i = 1 : nParts
    iPart = find(input(:,1)==i);
    if length(iPart) == 1
        input(iPart,:) = [];
    end
end


%if switches == 0 %treating all intensity data as a whole
    [Ij,Ik] = SemiIntensity(input(:,5)); %calculate Ij, Ik
    lRatios = LRatio(Ij,Ik,m); %and then the L-ratios
    b = zeros(4,1);
    for i = 1 : 4 %calculate 4 values for b
        b(i) = (3*r)/(lRatios(i) + 2);
    end
    %do the same for a
    a = zeros(4,1);
    for i = 1 : 4
        a(i) = (3*r)-(2*b(i));
    end
    %only values for which both are positive and non-zero make physical
    %sense...
%     for i = 1 : 4
%         if or(or(or(a(i) <= 0,b(i) <= 0),or(isnan(a(i)),isnan(b(i)))),or(isinf(a(i)),isinf(b(i))))
%             a(i) = 0;
%             b(i) = 0;
%         end
%     end
    
    %initialise the output
    output = zeros(4,2);
    for i = 1 : 4
        output(i,1) = a(i);
        output(i,2) = b(i);
    end
%    
% else %treating all particles as independent
%     output = {};
%     n = 0;
%     for i = 1 : nParts %loop over all the particles
%         ints = [];
%         while input(n,1) == i %pull out the intensities for one particle at a time
%             ints(end+1) = input(n,6);
%             n = n + 1;
%         end
%         %then do the same mjp on the content of ints.
%             
%     end
% end
