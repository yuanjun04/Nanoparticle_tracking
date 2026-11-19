%this code to analyse Strathclyde data

%set size limits of particles:
smallest = 21.5; %nm
largest = 85; %nm

%set the largest variance from mode to be used. Larger numbers will carry
%more statistical significnace, smaller numbers less. Too large, and the
%results will become nonsense as peaks splurge into each other.
variance_from_local_mode = 1; %nm

%read contents of datafile
all_data = readtable('Capture 2016-06-08 16-12-26_AllTracks.csv','Delimiter',',','ReadVariableNames',false);

%convert the table to a more useable cell array
all_data_cell = table2cell(all_data);

%ignore unused tracks
accepted_tracks = [];
for i = 2:(height(all_data)-1)
    if strcmp(all_data_cell{i,8},'TRUE')
        accepted_tracks(end+1,1) = str2double(all_data_cell{i,1});
        accepted_tracks(end,2) = str2double(all_data_cell{i,2});
        accepted_tracks(end,3) = str2double(all_data_cell{i,7});
    end
end
%now, accepted_tracks contains 1:particle number, 2:particle size, and
%3:intensity.

%Some versions of matlab (2013a and earlier I think?) require the following
%line to be uncommented - they generate a nonsense forst line in matrices
%generated like this which needs to be removed.
%accpeted_tracks(1,:) = [];

%make a sub-array of small particles
small_particles = [];
for i = 1:length(accepted_tracks(:,1))
    if and(accepted_tracks(i,2)>(smallest-variance_from_local_mode),accepted_tracks(i,2)<(smallest+variance_from_local_mode))
        small_particles(end+1,:) = accepted_tracks(i,:);
    end
end

%and the same for larger particles
large_particles = [];
for i = 1:length(accepted_tracks(:,1))
    if and(accepted_tracks(i,2)>(largest-variance_from_local_mode),accepted_tracks(i,2)<(largest+variance_from_local_mode))
        large_particles(end+1,:) = accepted_tracks(i,:);
    end
end


