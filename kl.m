%quick kl script

%empty arrays
dist1=zeros(10000,2);
dist2=zeros(10000,2);

%calculate curves
for i = 1 : 10000
    dist1(i,1)=(i/100)/1000000000;
    dist2(i,1)=(i/100)/1000000000;
    dist1(i,2)=gaussian_value(41.3/1000000000,1/1000000000,dist1(i,1));
    dist2(i,2)=gaussian_value(41.7/1000000000,1.6/1000000000,dist2(i,1));
end

%initialise kl values
d12=0;
d21=0;

%remove mutual zeros
for i = 1 : 10000
    if dist1(i,2)==0
        dist2(i,2)=0;
    end
    if dist2(i,2)==0
        dist1(i,2)=0;
    end
end

%calculate kl both ways
for i = 1 : 10000
    if dist1(i,2)~=0
        d12=d12+(dist1(i,2)*log(dist1(i,2)/dist2(i,2)));
        d21=d21+(dist2(i,2)*log(dist2(i,2)/dist1(i,2)));
    end
end
