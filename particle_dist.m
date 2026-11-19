function particle_distn = particle_dist(particle,fps,pxptch)
%particle is an array with two columns, containing x and y data for a
%particle over time. fps is the number of frames per second in the video
%file, so the time evolution between video frames may be easily
%calculated.pxptch is the pixel pitch.

movements = zeros(length(particle(:,1))-1,1);
for i = 1 : length(particle(:,1))-1
    movements(i) = abs(particle(i,1)-particle(i+1,1))+abs(particle(i,2)-particle(i+1,2));
end
%now movements keeps a track of the change in position of the particle
%between each pair of adjacent frames. This can then be transformed into a
%velocity with knowledge of the pixel pitch and the frame rate.

%this then converts the pixel movement data previously in movements into
%distance data
movements = movements*pxptch;

%and then this converts this distance per frame into a stepwise velocity.
movements = movements/fps;

%and then this result is returned to the calling function.
particle_distn = movements;
end
