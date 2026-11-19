function gausses = sample_dist(minimum,maximum,size)
%simple code to generate simulated intensity data for determining shape
%information of nanoparticles using NTA

g = zeros(size,abs(maximum-minimum));
if maximum > minimum
    for i = minimum : maximum
        g(:,i) = (normrnd(i,100,size,1))*(i^6);
    end
else
    for i = maximum : minimum
        g(:,i) = (normrnd(i,100,size,1))*(i^6);
    end
end
g = g(:);
gausses = g;
end