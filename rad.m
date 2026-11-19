function hydr=rad(particles,framerate)

%this function takes a list of particles and their positions, and returns
%the relative size, pending correction to the size of a single pixel in the
%original image. particles is an array with as many rows as necessary, and
%4 columns: particle number, frame number, x-co-ordinate, and y
%co-ordinate. It must be sorted foremost by increasing particle number, and
%secondarily by increasing frame number ie all the data for a single
%particle are sequantial and grouped together.

%it outputs a 3-column array, columns corresponding to particle size,
%standard error in particle size, and number of steps the particle was
%tracked for respectively.

%firstly, the input data are manipulated to make them as easy to handle
%later as possible...

%any rows that contain no particles are removed. This can sometimes happen
%if the sample has very few particles detected in it.
% len = length(particles(:,1));
% for k = 1 : length(particles(:,1))
%     if max(particles(len-k+1)) == 0
%         particles(len-k+1) = [];
%     end
% end

%this makes sure that the particle indices start from 1, not zero.
if particles(1,1)==0
    particles(:,1) = particles(:,1)+1;
end

%this makes sure that the frame numbers are counted from 1, not zero.
for i = 1 : length(particles(:,2))
    if particles(i,2) == 0
        particles(:,2) = particles(:,2)+1;
    end
end

%this calls a function to return an array containing the number of frames
%each particle turns up in, such that individual particles may be pulled
%out of the data
trcnt = particle_counter(particles);
%this isn't the original use of this function, so the documentation of
%'particle_counter' may be confusing when taken in the context of this
%code.

%count is a cumulative distance through the particle array, such that it is
%always possible to reference the subsequent particle detected
count = 0;

%create an empty array to hold the values for the mean, standard deviation,
%and number of steps for each particle
output = zeros(max(particles(:,1)),3);%

for j = 1 : max(particles(:,1))
    tracks = zeros(trcnt(j)-1,1);%to hold the length of each individual track
    avg = 0; %assign a variable for the average
    for k = 1 : (trcnt(j)-1) %the number of tracks is 1 fewer than the number of frames a particle is detected in.
        if (k+count) <= length(particles(:,1))
            sep = sqrt((abs(particles(k+count,3)-particles(k+count+1,3)))^2+(abs(particles(k+count,4)-particles(k+count+1,4)))^2);
            avg = (sep/k)+((k-1)/k)*avg; %this may be swapped out for lognormal mean
            tracks(k) = sep;
            count = count+1;
        end
    end
    number = length(tracks);
    stdev = std(tracks);% this may be swapped out for lognormal stdev
    output(j,1) = avg*framerate; %to obtain pixels per second
    output(j,2) = stdev*framerate; %scale the error accordingly. No implicit error in framerate
    output(j,3) = number; %number of steps per particle.
%     [freq,bins] = hist(tracks);
%     histo = zeros(length(freq),2);
%     for l = 1 : length(freq)
%         histo(l,1) = bins(l);
%         histo(l,2) = freq(l);
%     end
%     variable = lognormal(histo);
%     output(j,4) = variable(1);
end
     
%in the case of a particle that is only detected in a single frame, it is
%necessary to remove it, since it will not produce a track. Such a particle
%will produce the row in the output matrix (0,NaN,0), and so is easy to
%extract.

%for the purposes of later simplification, the length of the dataset will
%be written into a variable here
len = length(output(:,1));

%then, the output array is looped over, and any short tracks are weeded
%out.
for i = 1 : len-1
    if output(len-i,3) == 0
        output(len-i,:) = [];
    end
end

%finally, the last row often appears to contain eratic behaviour, so will
%be truncated
output(end,:) = [];

hydr = output;

end