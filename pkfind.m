function peaks = pkfind(data,peaks,npeaks)
%pkfind detects peaks in a distribution, data. Peaks is the list of peaks
%so far, ipeak is the current peak number, and npeaks is the total number
%of peaks to find.

%1st column of data is the centres, second column is the frequency density.


%use extrema to find a list of the local maxima and minima
[xmax,imax,xmin,imin] = extrema(data(:,2));

if length(xmax) < npeaks
    errordlg(strcat('You asked for more peaks than were detected in the data!',' ',num2str(length(xmax)),' peaks will be returned.'),'Insufficient peaks!')
    npeaks = length(xmax);
end

%strip out all the datapoints that aren't necessary
len = length(xmax);
for i = npeaks+1 : len
    xmax(npeaks+1) = [];
    imax(npeaks+1) = [];
end

%write the variable peaks.
for j = 1 : npeaks
    peaks(j,1) = data(imax(j),1);
    peaks(j,2) = data(imax(j),2);
end

% %establish maxima and minima on the distribution.
% datamax = max(data(:,1));
% datamin = min(data(:,1));
% 
% %define minimum seperation
% minsep = (datamax-datamin)/(3*npeaks); %the 3 is fairly arbitrary
% 
% %establish a 1st case.
% if ipeak == 1
%     peaks(1,1) = max(data(:,2));
%     for i = 1 : length(data(:,1))
%         if data(i,2) == peaks(1,1)
%             peaks(1,2) = data(i,1);
%         end
%     end
% else
%     %remove previous peaks
%     for i = 1 : ipeak
%         largepeak = max(data(:,2));
%         len = length(data(:,1));
%         for j = 1 : length(data(:,1))
%             if data(len-j+1,2) == largepeak
%                 data(len-j+1,:) = [];
%             end
%         end
%     end


end