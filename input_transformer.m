function [output] = input_transformer(video_path,init, final, maxdetectloops,img_switches,img_params,detection_params,step_length)
%this calls tracker.m and then transforms its output into the form required
%by rad.m: column 1 is particle number, column 2 is frame number, 3 is
%x-co-ordinate, 4 is y-co-ordinate, and 5 is zero-order intensity moment.

%it appears that column 2 is the frame number for that particle, with the
%particle first being detected in frame 1. This is not the absolute
%framenumber in which the particle is first detected.

%all input parameters are the same as those for tracker.m

%first, call tracker.m
input = tracker(video_path,init, final, maxdetectloops,img_switches,img_params,detection_params,step_length);

%remove all frames with no particles in them
% len = length(input);
% for k = 1 : length(input)
%     if isempty(input{len-k+1})
%         input(len-k+1) = [];
%     end
% end
        
%disp(input);
%make an empty cell. Each array in the cell corresponds to a single
%particle track.
particles = {};
nowframe = [];
for frame = 1 : length(input)-1 %loop through all possible frame transitions
    %disp('loop')
    row = 1; %new loop index
    untracked = 0;
    if size(input{frame}(:,1)) ~= 0 %make sure the frame in question isn't empty
        untracked = 1;
    end
    while untracked > 0
        if length(input{frame}(:,6)) >= row %check not all particles in that frame have been tracked
            try
                while and(input{frame}(row,6) == -1,untracked > 0) %skip unlinked particles, set fow to be the next particle in that frame that hasn't been tracked.
                    row=row+1;
                    if row >= length(input{frame}(:,1))
                        untracked = 0;
                    end
                end
            catch
                untracked = 0;
            end
        end
        [input,particles{end+1}] = single_track(input,frame,row); %follow a particle that was first detected in frame frame, in row row, in input data input.
        nowframe(end+1) = frame; %add an entry for this nth particle into the end of nowframe for later use.
        if row == length(input{frame}(:,1))
            untracked = 0;
        end
    end
%     nowframe(end+1) = frame; %add an entry for this nth particle into the end of nowframe for later use.
end

%calculate total number of datapoints
count = 0;
for i = 1 : length(particles)
    for j = 1 : length(particles{i}(:,1))
        count = count+1;
    end
end

%make empty array to hold all data
output = zeros(count,5);

%and a total loop index
loops = 1;

%and then copy all the data into one 2d array
for particle = 1 : length(particles)
    for iframe = 1 : length(particles{particle}(:,1))
        output(loops,1) = particle;
        %output(loops,2) = iframe;%this is wrong! Should give iframe to be the original frame the particle was first detected in!
        output(loops,2) = nowframe(particle);
        output(loops,3) = particles{particle}(iframe,2);
        output(loops,4) = particles{particle}(iframe,3);
        output(loops,5) = particles{particle}(iframe,4);%this is the intensity!
        loops = loops+1;
    end
end

%the first two columns are integers, so convert them to integers to save
%memory
for i = 1 : length(output(:,1))
    output(i,1) = int32(output(i,1));
    output(i,2) = int32(output(i,2));
end

end