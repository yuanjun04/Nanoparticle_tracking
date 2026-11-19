function outarray = particle_counter(particles)
%this function generates an array containing the number of particles in
%each frame of the video. It assumes that there is at least one particle
%visible in each frame. It also requires that the data be arranged in three
%columns, namely frame number, x-co-ordinate, and y-co-ordinate.
start = particles(1,1);
finish = max(particles(:,1));
array = zeros(finish-start+1,1);
len = length(particles(:,1));
for i = 1 : len
    if particles(i) == particles(i+1)
        array(start) = array(start) + 1;
    else
        start = start+1;
    end
end
array = array+1;
outarray = array;
end