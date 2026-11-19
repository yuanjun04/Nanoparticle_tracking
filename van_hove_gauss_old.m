function van_hove_correl=van_hove_gauss_old(particles,dimx,dimy,radius)
%particles should be an array containing three columns. The first should
%contain the frame number, while the second should contain the particle's
%x-y co-ordinates. These co-ordinates must be integer values of pixels.
%More precise centroids aren't supported. dimx and dimy are the dimensions
%of the original frame in pixels. Radius is the radius of the maximum halo
%to be fitted around the particle centroids. Layers gives the number of
%different virtual potentials to consider around the centroid. Value is the
%increment per shell of the calculated potential field.

%this function can only correlate particles to the first frame in the
%series. Subsequent correlations require the particles from the first video
%frame to be removed from the 'particles' array. The indices shouldn't have
%to be renumbered, since this function should scan through, find the first
%populated frame, and use that as a reference.

%This generates a blank matrix of the dimensions of the original input
%video, and fills it with zeros, ready to be populated with the particle
%'fields'
matrix = zeros(dimx+2*radius,dimy+2*radius);

%This necessitates that the particle positions be transposed by a suimilar
%amount
particles(:,2) = particles(:,2)+radius;
particles(:,3) = particles(:,3)+radius;

%This establishes the frame number of the first frame in which there were
%particles detected, or the reference frame for subsequent iterations of
%the program. This allows the particle array to just be truncated before
%each run of this van_hove loop to get subsequent correlations.
first_frame = 1;
ref = 0;
while ref == 0
    if particles(1) == first_frame
        ref = 1;
    else
        first_frame = first_frame+1;
    end
end

%This section builds up a reference matrix for the first frame

%This works out how many particles are in the first frame, and writes it to
%the variable particle_count
particle_count = 1;
ref_frame = 0;
while ref_frame == 0
    if particles(particle_count,1) == first_frame
        particle_count = particle_count+1;
    else
        ref_frame = 1;
    end
end

%This adds the contributions from all the particles in the reference frame
%to the reference matrix.
for i = 1 : particle_count-1
    matrix = sparse(draw_gaussian(matrix,radius,round(particles(i,2)),round(particles(i,3)),0,1));
end
%Now we have a reference matrix!

%then we call particle_counter, which generates an array containing the
%number of particles in each frame of the video
particles_per_frame = particle_counter(particles);


% Now we need to generate an additional matrix for every remaining frame in
% the data table. These matrices can in turn be placed within a 1D array,
% which is readily parsed since all the arrays are of identical dimensions.
% 
% Each array can be built up in exactly the same way that the reference
% matrix was, and then put into place in a pre-defined array the same length
% as the number of remaining frames.

matrices = zeros(max(particles(:,1)),dimx+2*radius,dimy+2*radius);

h = particles_per_frame(1);
for k = particles(1,1) : max(particles(:,1))-min(particles(1,1))-1
    matri = sparse(zeros(dimx+2*radius,dimy+2*radius));
    for o = 1 : particles_per_frame(k)
        h = h+1;
        matrices(k,:,:) = draw_gaussian(matri,radius,round(particles(h,2)),round(particles(h,3)),0,1); 
    end
end

%now each of these subsequent frames needs to be correlated to the initial
%frame.
correl = cell(length(matrices(:,1,1)),1);
for p = 1 : length(matrices(:,1,1))
    q = zeros(length(matrices(1,:,1)),length(matrices(1,1,:)));
    for r = 1 : length(matrices(1,:,1))
        for s = 1 : length(matrices(1,1,:))
            q(r,s) = matrices(p,r,s);
        end
    end
%     correl{p} = xcorr2(matrix,q);
    correl{p} = 1/(sum(sum((matrix-q).^2)));
end



van_hove_correl = cell2mat(correl);




% % and now matrices contains a matrix for every frame apart from the first
% % reference frame!
% % 
% % Now we need to generate a correlation coefficient between the first
% % reference matrix and all the subsequent matrices.
% % 
% % First the matrices need trimming down to the size of the original FoV...
% % matrix = trim_matrix(matrix,radius); for t = 1 : length(matrices)
% %    matrices(t) = trim_matrix(matrices(t),radius);
% % end
% % 
% % Next create an array of correlation matrices, containing the squared
% % (positive) differences between the reference frame and subsequent frames.
% % matrixd = zeros(1,length(matrix(1,:)),length(matrix(:,1)));
% % matrixd(1,:,:) = matrix;
% % difference_matrices = zeros((length(matrices(:,1,1))),(length(matrices(1,:,1))),(length(matrices(1,1,:))));
% % for q = 1 : length(matrices(1))
% %     difference_matrices(q,:,:) = power((matrixd-matrices(q,:,:)),2);
% % end
% % Then create a list of the sum of the squared difference, and take its
% % reciprocal to generate a correlation value between each frame and the
% % reference.
% % 
% % difference_sums = zeros(length(difference_matrices(:,1,1)));
% % for r = 1 : length(difference_sums)
% %     difference_sums(r) = 1/(sum(difference_matrices(r,:)));
% % end
% % This gives a 1D array containing the correlation coefficients.
% % 
% % All it takes now is to return these values to the function call.
% % van_hove_correl = difference_sums;
end