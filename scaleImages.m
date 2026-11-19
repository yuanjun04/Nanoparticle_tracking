%
% SCALEIMAGES:
%    reads images, normalizes to global extrema and stores
%    images again using fixed-width numbering format.
%    optionally displays every frame.
%    If the images are multi-channel (color), all channels will be
%    scaled and the extrema will additionally be taken over
%    channels.
%
% SYNTAX: 
%    scaleImages(instub,first,last,infmt,outstub,ext,outfmt,viz)
% 
% INPUT ARGUMENTS:
%    instub          location and file name stub of input files
%    first           number of first image to process
%    last            number of last image to process
%    infmt           numbering format of input file names (see below)
%    outstub         location and file name stub of output files
%    ext             file extension of input and output
%    outfmt          numbering format of output file names (see below)
%    viz             =1 to show every frame, =0 to show nothing
%
% RETURN VALUE:
%    none.
%
% FORMATS:
%    infmt and outfmt specify the file numbering format for input and
%    output as follows: if the parameter is equal to an integer number >0
%    is specifies the number of digits in a fixed numbering (e.g. infmt=3
%    -> 001, 002, ..., 010, 011, ..., 100, 101, ..., 999) if the parameter
%    is equal to the string 'free', the numbering is free format (i.e.
%    infmt='free' -> 1, 2, 3, ..., 10, 11, ..., 100, 101, ...).
%
% AUTHOR:
%    Ivo Sbalzarini, ETHZ, February 10, 2004
%
% VERSION:
%    0.2 rev.A
%

%-------------------------------------------------------------------
% No user-adjustable parameters below this line
%-------------------------------------------------------------------

function scaleImages(instub,first,last,infmt,outstub,ext,outfmt,viz)

    % argument validity checks
    if or(nargin<8, nargin>8),
	disp('ERROR: wrong number of input arguments. See "help prepareImages" !');
	return;
    end;
    if length(instub)<2,
	disp('ERROR: instub must be a non-empty string !');
	return;
    end;
    if length(outstub)<2,
	disp('ERROR: outstub must be a non-empty string !');
	return;
    end;
    if or(first<0, length(first)>1),
	disp('ERROR: first must be a non-negative integer !');
	return;
    end;
    if or(last<0, length(last)>1),
	disp('ERROR: last must be a non-negative integer !');
	return;
    end;
    if last<first,
	disp('ERROR: last must be larger than first !');
	return;
    end;
    if or(and(length(round(infmt))>1, ~strcmp(infmt,'free')),round(infmt)<1),
	if ~strcmp(infmt,'free'), infmt = round(infmt); end;
	disp('ERROR: infmt must be a positive integer or "free"');
	return;
    end;
    if or(and(length(round(outfmt))>1, ~strcmp(outfmt,'free')),round(outfmt)<1),
	if ~strcmp(outfmt,'free'), outfmt = round(outfmt); end;
	disp('ERROR: outfmt must be a positive integer or "free"');
	return;
    end;
    if and(viz ~= 0, viz ~= 1),
	disp('ERROR: viz must be either 0 or 1 !');
	return;
    end;
    if sum(strcmp(ext,{'tif','jpg','bmp','png','hdf','pcx','xwd'})) ~= 1,
	disp('ERROR: ext must be one of the following: tif,jpg,bmp,png,hdf,pcx,xwd');
	return;
    end;

    % read files and determine global extrema
    [imin,imax] = getGlobalExtrema(instub,first,last,infmt,ext);

    disp(' ');
    disp('rescaling and renaming files ...');

    % second read: normalize images and store using new file names
    for img=round(first):round(last),
	file = getFileName(img,infmt,instub,ext);
	a = double(imread(file));
	b = (a-imin)/(imax-imin);
	outfile = getFileName(img,outfmt,outstub,ext);
	imwrite(b,outfile,ext)
	if viz,
	    disp('Displaying movie in figure 1. Press any key to proceed to next frame');
	    figure(1)
	    clf
	    imshow(b)
	    pause
	end;
    end;

    disp('done.');
    return;
% end;         function scaleImages

