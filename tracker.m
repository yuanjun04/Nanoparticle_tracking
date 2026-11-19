%====================================================================== 
%
% TRACKER: track virus particles in a time series of images
%
% SYNTAX:  peaks = tracker(filestub, ext, init, final, maxdetectloops)
%
% INPUTS:  filestub       stub of frame image file names incl. path
%          ext            extension of file names (with the dot, eg '.tif')
%          init           number of initial frame
%          final          number of final frame
%          maxdetectloops maximum number of iterations for the particle
%                         detection algorithm. Recommended less than 100,
%                         nothing bad seems to happen at 10.
%          video_path
%
% The input files are expected to be called <filestub>[init..final]
% with subsequent numbering referring to the corresponding frame
% in the movie.
%
% The feature detection step is implemented in parallel and can make
% use of several matlab processors either through the parMATLAB
% toolbox or the MPI toolbox (need to be installed).
%
% After detection, a cell list of matrices is returned in
% "peaks". peaks{iframe} contains the particle information
% for frame i stored in a matrix. Two different routines
% both for feature detection and particle matching (linking
% of the trajectories) are available:
%
%    Detection: detect_particles
%    Linking:   link_trajectories
%
% The final output that is returned is:
%         peaks{iframe}(:,1)    x (col)-positions of particles
%         peaks{iframe}(:,2)    y (row)-positions of particles
%         peaks{iframe}(:,3)    zero order intensity moments
%         peaks{iframe}(:,4)    second order intensity moments
%         peaks{iframe}(:,5)    *** unused ***
%         peaks{iframe}(:,6)    link list index of same part.
%                               in next frame. -1 if none.
%
% This cell list is also stored in the file "trackdata" for later use.
%
% USES:    detect_particles, link_trajectories
%
% Ivo Sbalzarini, Feb. 12, 2003
% Institute of Computational Science, Swiss Federal
% Institute of Technology (ETH) Zurich. 
% E-mail: sbalzarini@inf.ethz.ch
%
%modified for R2013a by S Thompson, University of York, UK 24.3.2014
%and several times further, up to 2015b, 2.12.2015
%
%and remodified again to allow for image denoising at the point of reading
%an AVI video rather than a string of TIF images. This makes it vastly
%faster when running off a slow hard drive. The hard-drive limited read
%process is offset by interleaving with the processor-limited denoising
%step. This gives it good scalability to about 3 processors before
%flatlining.
%
%Due to large integer reliance, this will tend to run slightly better on
%AMD bulldozer/piledriver based systems (2+ integer units per core) than on
%Intel (1 integer unit per core). This advantage only exists on
%AMD64/x86_64 architectures, and may/will disappear on other systems (ia64, 
%POWER, SPARC etc) because these aren't
%bulldozer/piledriver/excavator-based architectures. 
%====================================================================== 

%function peaks = tracker(filestub, ext, init, final,maxdetectloops)
function peaks = tracker(video_path,init,final,maxdetectloops,img_switches,img_params,detection_params,step_length)
%=============================================================
% User-adjustable parameters below
%=============================================================

%----------------------------------------------------
% general parameters
%----------------------------------------------------
% if length(filestub) == 0,
%     filestub = '';   % default stub of image file names
% end;
% if length(ext) == 0,
% %     ext = '';   % default extension of image file names
% end;
para = 0;      % parallel (1) or serial (0) version?
parsys = 'parMATLAB';  % 'PM'  % parMATLAB (PM) or MPI (MPI) ?
viz = 0;       % visulaize images?
% list of machine names for parallel execution using MPI.
% The list can be of any length > 0.
machines = {};

%----------------------------------------------------
% parameters for detect_particles, link_trajectories
%----------------------------------------------------
%w = 3;         % radius of neighborhood: > particle radius, 
w = detection_params(1);
               % < interparticle distance
%cutoff = 0.5;  % probability cutoff for non-particle
cutoff = detection_params(2);
               % discrimination
%pth = 1;       % upper intensity percentile for particles
pth = detection_params(3);
%L = 5;        % maximum displacement between frames
L = step_length;

%-------- No more user-adjustable settings below this line ---------

%=============================================================
% If parallel version: init parMATLAB or MPI
%=============================================================

if para,
    viz = 0;    % parallel and visualization are mutually exclusive
    if strcmp(parsys,'PM'),
        disp('Parallel version using parMATLAB. Start workers now!')
        [ss,rs] = initmajordomo;
    elseif strcmp(parsys,'MPI'),
        disp('Parallel version using MPI.')
        if (length(machines) < 1),
            disp('No machines specified. Aborting.')
            return;
        end;
        for imachine=1:length(machines),
            s = psetup(machines{imachine},1);
            if s<0, 
                disp(sprintf('Cannot setup %s',machines{imachine})) 
            end;
        end;
    end;
end;

%=============================================================
% read images and determine global extrema
%=============================================================

if viz ==1,
    nfig = 1;
else
    nfig = -1;
end;
nfig = -1; %force no graph
%disp('Scanning files for minimum and maximum intensity values...')
maxint = -Inf;
minint = Inf;
numsat = 0;
%check if avi or frames
if strcmp(video_path(end),'i')
    faster = 0;
elseif strcmp(video_path(end),'s')
    faster = 1;
else
    errordlg('Something went wrong with your video file shat shouldn''t have been able to...');
    return %and throw error if I can be bothered.....
end
progressbar('Pre-processing video')
if ~faster
    vid_raw = VideoReader(video_path);
elseif faster
    frames_path = video_path;
    while ~strcmp(frames_path(end),'/')
        frames_path = frames_path(1:end-1);
    end
end
for img=init:final,
    %img
    progressbar(img/final)
    %file = sprintf('%s%d%s',filestub,img,ext);
    if ~faster
        try %make sure only one colour channel is used for the normalisation proceedure.
            orig = rgb2gray(imageprocess(read(vid_raw,img),img_switches,img_params));
        catch
            orig = imageprocess(read(vid_raw,img),img_switches,img_params);
        end
    elseif faster
        try
            orig = rgb2gray(imageprocess(imread(strcat(frames_path,'image',num2str(img-1),'.tif')),img_switches,img_params));
        catch
            orig = imageprocess(imread(strcat(frames_path,'image',num2str(img-1),'.tif')),img_switches,img_params);
        end
    else
        errordlg('Something impossible happened. Tachyon science calls you!');
        return
    end
    %orig = double(imread(file));
    locmax = max(max(orig));
    locmin = min(min(orig));
    if locmax > 254
        numsat = numsat+1;
    end;
    if locmax > maxint
        maxint = locmax;
    end;
    if locmin < minint
        minint = locmin;
    end;
    %correct for colour images:
    orig_size = size(orig);
    if length(orig_size) == 3 %if there's more than one layer to the image
        %new_orig = zeros(orig_size(1),orig_size(2));
        %for layer = 1 : orig_size(3)
        orig = rgb2gray(orig(:,:,:));
        
           
        %end
        %orig = round(new_orig/3); %and replace the original with the new one...
    end
    images(:,:,img-init+1) = orig;
end;
nimg = final-init+1;
%disp(sprintf('%d frame images successfully read',nimg))
%disp(sprintf('Minimum intensity value is: %f',minint))
%disp(sprintf('Maximum intensity value is: %f',maxint))
if numsat > 0,
    %disp(sprintf('WARNING: found %d saturated pixels !',numsat))
end;

%=============================================================
% normalize all images
%=============================================================
% 
% for img=1:nimg,
%     images(:,:,img) = (images(:,:,img)-minint)./(maxint-minint);
% end;
% disp(size(images));
% disp(size(maxint));
% disp(size(minint));
images(:,:,:) = (images(:,:,:) - minint)./(maxint-minint);%do it the matlab way...

%=============================================================
% detect particles in all image frames
%=============================================================

if para,
    if strcmp(parsys,'PM'),
        xpix = size(images,1);
        ypix = size(images,2);
        pindices = [1 1 1 xpix xpix; 2 1 1 ypix ypix; ...
                3 nimg 1 1 1];   % image decomp. indices
        skalind  = [0 nimg 1 0 1];   % scalar constant indices
	v = [viz, nfig];
	vecind = [2 nimg 1 0 2];
        peaks = parallelize(ss,rs,1,1,'detect_particles',1, ...
              images,pindices,w,skalind,cutoff,skalind,pth, ...
              skalind,v,vecind);
    elseif strcmp(parsys,'MPI'),
        pfor(1:nimg,'peaks(%d)=detect_particles(images(:,:,%d),w,cutoff,pth,[viz,nfig])');
    end;
else
    peaks = [];
    progressbar('Detecting particles')
    for img=1:nimg,
        %disp(sprintf('\nParticle recoginition in image %d of %d',img,nimg))
        progressbar(img/nimg)
%         if viz == 1,
%             figure(nfig)
%             nfig = nfig + 1;
%             imshow(images(:,:,img))
%             title('Original micrograph');
%         end;
        peak = detect_particles(images(:,:,img),w,cutoff,pth,[viz,nfig],maxdetectloops);
        peaks = [peaks, peak];
    end;%startindex
end;

if para,
    if strcmp(parsys,'PM'),
        closemajordomo(ss,rs);
    elseif strcmp(parsys,'MPI'),
        MPI_Finalize;
    end;
end;

%=============================================================
% assemble paths across frames as linked list
%=============================================================

peaks = link_trajectories(peaks, L, viz, 100);

% save data for later use
save trackdata peaks;

%=============================================================
% visualize paths  
%=============================================================

%file = sprintf('%s%d%s',filestub,init,ext);
%orig = double(imread(file));
%[orig] = normalize(orig);
%nframe = length(peaks);

% figure(200)
% clf
% imshow(orig)
% hold on

% C = peaks{1}(:,1);
% R = peaks{1}(:,2);
% X = [[C'-2; C'+2], [C'; C']];
% Y = [[R'; R'], [R'-2; R'+2]];
% hand = line(X,Y);
% set(hand(:),'Color',[1 0 0]);
% for iframe=2:nframe,
%     oldind = find(peaks{iframe-1}(:,6)>0);
%     curind = peaks{iframe-1}(oldind,6);
%     X = [peaks{iframe-1}(oldind,1), peaks{iframe}(curind,1)];
%     Y = [peaks{iframe-1}(oldind,2), peaks{iframe}(curind,2)];
%     hand = line(X',Y');
%     set(hand(:),'Color',[1 0 0]);
%     set(hand(:),'LineWidth',[1.0]);
% end;
% hold off

