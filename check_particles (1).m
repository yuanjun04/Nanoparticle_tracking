function output = check_particles(w,cutoff,pth,maxdetectloops,img)

%this calls the same function train as the process button, but it just
%detects particles in a single frame and returns their locations. These can
%then be superimposed upon the camera image.


%if takes the same variables that tracker.m takes...

viz = 0;
nfig = 0;

try
    img = rgb2gray(img);
catch
    img = img;
end

peak = detect_particles(img,w,cutoff,pth,[viz,nfig],maxdetectloops);

output = peak{1,1};
