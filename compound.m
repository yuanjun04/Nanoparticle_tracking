function output = compound(particles,framerate,min_length,maxdev,driftx,drifty)

%This function compounds the functions of rad, track_trim, sterr, and
%accuracy into a single common-sense function.

%it also adds the driftx and drifty parameters to correct for drift,
%usually from convection of the sample, though it will also correct for
%drift that arises from pumping of particles to achieve better statistical
%significance.

%function hydr=rad(particles,framerate)

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

%test it...
%disp(particles);

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
output = zeros(max(particles(:,1)),4);%...and another column for the intensity makes 4!

%test it
%disp(particles);

if or(~isempty(driftx), ~isempty(drifty))
    %do something with incorporated drift correction
    
    %populate any unused corrections with a null correction...
    if isempty(driftx)
        driftx = zeros(length(drifty),1);
    end
    if isempty(drifty)
        drifty = zeros(length(driftx),1);
    end
    disp(drifty);
    for j = 1 : max(particles(:,1))
        try %this should stop it failing if there are no particles in a frame. Don't know what the performance penalty of this will be, hopefully not too large...
            trcnt(j); %this was where it kept failing.
        catch
            output(j,1) = 0; %make sure there's still something for that iteration of the loop to output
            output(j,2) = 0;
            output(j,3) = 0;
            output(j,4) = 0;%intensity
            continue %skip this iteratin of the for loop next up in the nest so nothing else fails
        end
        tracks = zeros(trcnt(j)-1,1);%to hold the length of each individual track
        avg = 0; %assign a variable for the average
        for k = 1 : (trcnt(j)-1) %the number of tracks is 1 fewer than the number of frames a particle is detected in.
            if (k+count) <= length(particles(:,1))
                xnew = particles(k+count+1,3);
                xold = particles(k+count,3);
                xchange = xnew-xold;
                xcorrected = xchange-driftx(k);
                ynew = particles(k+1+count,4);
                yold = particles(k+count,4);
                ychange = ynew-yold;
                %disp(drifty(k));
                ycorrected = ychange-drifty(k);
                sep = sqrt((xcorrected^2)+(ycorrected^2));
                %sep = sqrt((abs(particles(k+count+1,3)-particles(k+count,3)-driftx(k)))^2+(abs(particles(k+count+1,4)-particles(k+count,4)-drifty(k)))^2);
                avg = (sep/k)+((k-1)/k)*avg; %this may be swapped out for lognormal mean
                tracks(k) = sep;
                count = count+1;
                disp('avg =');
                disp(avg);
            end
        end
        number = length(tracks);
        stdev = std(tracks);

        %catch zeros
        if avg == 0
            stdev = 0;
        end
        
        disp('avg=');
        disp(avg);
        disp('framerate=');
        disp(framerate);

        output(j,1) = avg*framerate;
        output(j,2) = stdev*framerate;
        output(j,3) = number;
        output(j,4) = particles(j,5);%intensity
    %     [freq,bins] = hist(tracks);
    %     histo = zeros(length(freq),2);
    %     for l = 1 : length(freq)
    %         histo(l,1) = bins(l);
    %         histo(l,2) = freq(l);
    %     end
    %     variable = lognormal(histo);
    %     output(j,4) = variable(1);
    end    
    
else
    %something without drift correction
    for j = 1 : max(particles(:,1))
        tracks = zeros(trcnt(j)-1,1);%to hold the length of each individual track
        avg = 0; %assign a variable for the average
        for k = 1 : (trcnt(j)-1) %the number of tracks is 1 fewer than the number of frames a particle is detected in.
            if (k+count) <= length(particles(:,1))
%                 sep = sqrt((abs(particles(k+count,3)-particles(k+count+1,3)))^2+(abs(particles(k+count,4)-particles(k+count+1,4)))^2);
                xnew = particles(k+count+1,3); 
                xold = particles(k+count,3);
                xchange = xnew-xold;
                ynew = particles(k+1+count,4);
                yold = particles(k+count,4);
                ychange = ynew-yold;
                sep = sqrt((xchange^2)+(ychange^2));
                avg = (sep/k)+((k-1)/k)*avg; %this may be swapped out for lognormal mean
                tracks(k) = sep;
                count = count+1;
                %disp('correct');
            end
        end
        number = length(tracks);
        stdev = std(tracks);% this may be swapped out for lognormal stdev
        %catch zeros
        if avg == 0
            stdev = 0;
        end
        
        %test it
%         avg
%         stdev
%         framerate
        
        
        output(j,1) = avg*framerate; %to obtain pixels per second. This has been checked.
        output(j,2) = stdev*framerate; %scale the error by the same. No implicit error in framerate
        output(j,3) = number; %add the number of steps to the array
        output(j,4) = particles(j,5); %intensity is added.
    %     [freq,bins] = hist(tracks);
    %     histo = zeros(length(freq),2);
    %     for l = 1 : length(freq)
    %         histo(l,1) = bins(l);
    %         histo(l,2) = freq(l);
    %     end
    %     variable = lognormal(histo);
    %     output(j,4) = variable(1);
    end
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
%disp(output);
for i = 1 : len-1
    if output(len-i,3) == 0
        output(len-i,:) = [];
    end
end

%finally, the last row often appears to contain eratic behaviour, so will
%be truncated
output(end,:) = [];

hydr = output;


%-----------------------------------------------------------------------



    
%function output = track_trim(particles,min_length,framerate)

    %this is a simple function that calls 'rad' to calculate the particle track
%statistics, and then cuts out any particle data for particles with track
%lengths shorter than the specified min_length

%first, the particle step length analysis is carried out
%data = rad(particles,framerate);
data = hydr;

%for the purposes of later simplification, the length of the dataset will
%be written into a variable here
len = length(data(:,1));

%then, the output array is looped over, and any short tracks are weeded
%out.
for i = 1 : len-1
    if data(len-i,3) < min_length
        data(len-i,:) = [];
    end
end

%to get rid of the slightly dodgly (and possibly incomplete) last track
data(end,:) = [];

output = data;



%------------------------------------------------------------------


%function output = sterr(particles,min_length,framerate)


%this function calls track_trim to generate an output, and then adds a
%fourth column onto the output that contains the standard error in each
%mean step length calculated.

%call track_trim
%data = track_trim(particles,min_length,framerate);
data = output;

%make a new empty array to copy all the data into
new_data = zeros(length(data(:,1)),5); %5th column is for intensity

%loop over every row in the original table, and copy the values across
for i = 1 : length(data(:,1))
    new_data(i,1) = data(i,1);
    new_data(i,2) = data(i,2);
    new_data(i,3) = data(i,3);
    new_data(i,4) = data(i,2)/sqrt(data(i,3)); %not forgetting to do the standard error calculation...
    new_data(i,5) = data(i,4);%intensity
end

%and set the output variable equal to the new data table
output = new_data;




%---------------------------------------------------------------------


%function output = accuracy(particles,min_length,maxdev,framerate)


%this calls sterr (and all subfunctions) to perform track length analysis.
%It also adds the extra variable maxdev, which is the maximum permitted
%percentage of the mean track length that the standard error may be. It is
%recommended to use a value below 100%

%first, sterr is called for the data processing
%data = sterr(particles,min_length,framerate);
data = output;

%for later ease, the length of the dataset is written to a variable here
len = length(data(:,1));

%loop over entire dataset, and remove rows corrensponding to non-conforming
%values.
for i = 1 : (len-1)
    if (data(len-i,4)/data(len-i,1)) > (maxdev/100)
        data(len-i,:) = [];
    end
end

%check output isn't empty
if isempty(data)
    disp('There were no tracks discovered that comply with your settings.')
end

%write output
output = data;

end
