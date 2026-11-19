function xscr = xcr(particles,dimx,dimy,radius,type)

%this function is identical to 'van_hove_gauss', except that it uses the
%built-in xcorr function rather than my bespoke correlation function. This
%means that it runs significantly slower. Wheather it produces better
%results remains to be seen.

%particles should be an array containing three columns. The first should
%contain the frame number, while the second should contain the particle's
%x-y co-ordinates. These co-ordinates must be integer values of pixels.
%More precise centroids aren't supported. dimx and dimy are the dimensions
%of the original frame in pixels. Radius is the radius of the maximum halo
%to be fitted around the particle centroids.

%the 'type' variable can be used to tell the program to execute using
%either single or double precision floats. Single is highly recommended for
%RAM considerations. See documentation on multi_xcr for more information.

%this function can only correlate particles to the first frame in the
%series. Subsequent correlations require the particles from the first video
%frame to be removed from the 'particles' array. The indices shouldn't have
%to be renumbered, since this function should scan through, find the first
%populated frame, and use that as a reference.

%in order for this function to work properly, it currently requires that
%every frame within a scanned sample contain at least one particle. Future
%revisions may update this to allow it to produce effective results
%scanning more dilute samples.

%this parses the 'type' input to determine the type of execution required.
single = strcmp('single',type);

%this is the (safer and less RAM-heavy) single-precision routine
if single == 1
    
    %firstly, the input data now needs to be converted to 'single' format.
    %particles = single(particles);
    
    %This generates a blank matrix of the dimensions of the original input
    %video, and fills it with zeros, ready to be populated with the particle
    %'fields'
    matrix = zeros(dimx+2*radius,dimy+2*radius,'single');

    %if the sample being processed doesn't start on the first frame of video,
    %this allows the same routine to treat it
    if particles(1,1) ~= 1
        particles(:,1) = particles(:,1)-particles(1,1)+1;
    end

    %and if the first frame is numbered zero, this also needs to be corrected
    %for...
    if particles(1,1) == 0
        particles(:,1) = particles(:,1)+1;
    end

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
        matrix = draw_gaussian_single(matrix,radius,round(particles(i,2)),round(particles(i,3)),0,1);
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

    %the normal way of creating a blank 3d array uses too much memory, so
    %it has to be built up in steps from smaller empty sparse arrays.
%     component = sparse(dimx+2*radius,dimy+2*radius);
%     matricescell = {};
%     for w = 1 : max(particles(:,1))-particles(1,1)
%         matricescell{end+1} = component;
%     end
    
    %then the resulting sparse cell needs to be converted into a matrix
    %matrices = cell2mat(matricescell);
    
    %and now this can be made single precision to further minimise memory
    %consumption
    %matrices = single(matrices);
    
    matrices = zeros(max(particles(:,1))-particles(1,1),dimx+2*radius,dimy+2*radius,'single');
    h = particles_per_frame(1)-1; %starts from here so ignores particles from 1st frame
    for k = particles(1,1)+1 : max(particles(:,1))
        matri = zeros(dimx+2*radius,dimy+2*radius,'single');
        for o = 1 : particles_per_frame(k)
            h = h+1;
            matrices(k,:,:) = draw_gaussian_single(matri,radius,round(particles(h,2)),round(particles(h,3)),0,1);
        end
    end

    %because diff is such a large matrix, it needs to be sparse in order
    %for matlab to allocate sufficient memory to it.
    component = sparse((2*(length(matrices(1,:,1))))-1,length(matrices(1,1,:))^2);
    diffcell = {};
    for w = 1 : length(matrices(:,1,1))
        diffcell{end+1} = component;
    end
    
    %diff = cell2mat(diffcell);
    
    %then the next step is to apply the xcorr2 function to the system.
    %diff = zeros(length(matrices(:,1,1)),(2*(length(matrices(1,:,1))))-1,length(matrices(1,1,:))^2,'single');
    for x = 1 : length(matrices(:,1,1))
        %unfortunately, xcorr2 cannot manage a 2d slice taken from a 3d
        %array, which is rather silly of it. Therefore, an extra routine
        %that pulls out the second two dimensions from the 3d array is
        %necessary in order to be able to feed xcorr2 the correct input.
        sub_matrices = matrix_reorientate(matrices,x);
        diffcell(x,:,:) = mat2cell(xcorr2(matrix,sub_matrices));
    end
    diff = cell2mat(diffcell);
    %then the sum correlation may be taken and written to variable 'correl'
    correl = zeros(length(matrices(:,1,1)),1,'single');
    for y = 1 : length(matrices(:,1,1))
        correl(y) = sum(sum(diff(y,:,:)));
    end

    xscr = correl;

%what follows below is the double precision variation. This is stupidly the
%default behaviour and should only be used by an experienced user.
else
    %This generates a blank matrix of the dimensions of the original input
    %video, and fills it with zeros, ready to be populated with the particle
    %'fields'
    matrix = zeros(dimx+2*radius,dimy+2*radius);

    %if the sample being processed doesn't start on the first frame of video,
    %this allows the same routine to treat it
    if particles(1,1) ~= 1
        particles(:,1) = particles(:,1)-particles(1,1)+1;
    end

    %and if the first frame is numbered zero, this also needs to be corrected
    %for...
    if particles(1,1) == 0
        particles(:,1) = particles(:,1)+1;
    end

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
        matrix = draw_gaussian(matrix,radius,round(particles(i,2)),round(particles(i,3)),0,1);
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

    matrices = zeros(max(particles(:,1))-particles(1,1),dimx+2*radius,dimy+2*radius);
    h = particles_per_frame(1)-1; %starts from here so ignores particles from 1st frame
    for k = particles(1,1)+1 : max(particles(:,1))
        matri = zeros(dimx+2*radius,dimy+2*radius);
        for o = 1 : particles_per_frame(k)
            h = h+1;
            matrices(k,:,:) = draw_gaussian(matri,radius,round(particles(h,2)),round(particles(h,3)),0,1);
        end
    end

    %then the next step is to apply the xcorr2 function to the system.
    diff = sparse(zeros(length(matrices(:,1,1)),(2*(length(matrices(1,:,1))))-1,length(matrices(1,1,:))^2));
    for x = 1 : length(matrices(:,1,1))
        diff = sparse(diff);
        diff(x,:,:) = xcorr2(matrix,matrices(x,:,:));
    end

    %then the sum correlation may be taken and written to variable 'correl'
    correl = zeros(length(matrices(:,1,1)),1);
    for y = 1 : length(matrices(:,1,1))
        correl(y) = sum(sum(diff(y,:,:).^2));
    end

    xscr = correl;

end