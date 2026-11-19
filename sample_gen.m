function sample = sample_gen(particles,iterations,current_iteration,frames)
%this function generates a sub-matrix containing the a small subset of the
%particle data based on various contraints.

%it is necessary to know how many particles are in which frames so that the
%right number of frames may be evaluated.
particles_per_frame = particle_counter(particles);

sample_spacing = round(max(particles(:,1))/iterations);
start = (sample_spacing*(current_iteration-1))+1; %this is quite convoluted
%to ensure that it will always start on the first particle rather than a
%distance sample_length from the start.

%this catches the case that the program tries to read information on
%particles beyond the end of the dataset.
if start + frames > max(particles(:,1))
    start = max(particles(:,1))-frames;
end

%this figures out the required length for an array containing the relevant
%number of frames
len = 0;
for w = start : start+frames
    len = len+particles_per_frame(w);
end

%creates an array to contain the required sample of particle data
sub_particle = zeros(len,3);

%loop over this to build up the new sub array from the original full array
for i = 1 : len
    sub_particle(i,:) = round(particles(i+start,:));
end

sample = sub_particle;

end