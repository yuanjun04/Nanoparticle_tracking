En = zeros(100,2);
for i = 1 : 100
    En(i,1) = i;
    for j = 1 : 1000
        En(i,2) = (400/100)*(100-i) + (En(i,2)/100*((81/100)*i));
    end
    En(i,2) = En(i,2)+0.9*En(i,2);
end
