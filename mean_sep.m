function msp = mean_sep(particles)
%particles is an array with three columns for frame number, xpos, and ypos.

%Makes sure the array starts at frame index 1
if particles(1,1) ~= 1
    particles(:,1) = particles(:,1)-(particles(1,1)-1);
end

%generates a list of the number of particles in each frame of video
count = particle_counter(particles);

%create a blank array to hold the mean separation for each frame
len = zeros(length(count),1);

cumul = 0; %cumulative particle count

for i = 1 : length(count)
    if cumul == 0
        cumul = 0; %do nothing
    else
        cumul = cumul+count(i-1); %particles up to current frame
    end
    for j = 1 : count(i)
        for k = j : count(i)
            len(i) = len(i) + abs(sum((particles(cumul+j,[2 3])-particles(cumul+k,[2 3]))));
        end
    end
end
for l = 1 : length(len)
    len(l) = len(l)/count(l);
end

msp = len;
        