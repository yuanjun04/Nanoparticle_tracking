function number = lognormal(input)
%This file contains a full set of lognormal fitting code, as described in:

%Deposition of polycrystalline thin films with controlled grain size, by  
%Vopsaroiu, M.; Fernandez, G Vallejo; Thwaites, M J; Anguita, J; Grundy, P
%J; O'Grady, K
%J. Phys D 2005

%to run this code, make sure this file is in the matlab path, and ensure
%that the data to be analysed is stored in an arbitrary variable. Run the
%code by typing lognormal(YOUR_VARIABLE) into the matlab prompt.

%the input should be a 2 column array, containing histogram data of bin
%value for diameter and frequency. ie 1st column contains the diameter
%associated with that bin, and the 2nd column contains the associated
%frequency densities. It works for an arbitrary number of bins.

%the output is a 3 element column vector containing mean, standard
%deviation, and median diameter

%All code herein (c) S. Thompson, University of York, 2014.
%st643@york.ac.uk

number = zeros(3,1);
number(1) = l3(input);
number(2) = standev(input);
number(3) = m6(input);
end

function out1 = lnarray(input)
%this creates a 1-column array containing the logarithms of the diameters

%create a blank array
logarray = zeros(length(input(:,1)),1);

%loop over the array elements and write the new values into the output
for i = 1 : length(input(:,1))
    logarray(i) = log(input(i,1));
end

out1 = logarray;
end

function out2 = nlndarray(input)
%this creates an array containing the product of the logarithm of particle
%diameter and the frequency of that interval
%this function only exists as a placemarker, so the first function has a
%null value
%create blank array
weightlogarray = zeros(length(input(:,1)),1);

%call lnarray
logarray = lnarray(input);

%loop over the array and insert the values
for i = 1 : length(input(:,1))
    weightlogarray(i) = input(i,2)*logarray(i);
end

out2 = weightlogarray;
end

function out3 = nlnd2(input)
%this calculates the square of the logarithm multiplied by the frequency

%create blank array
nlogd2 = zeros(length(input(:,1)),1);

%call lnarray
logarray = lnarray(input);

%loop over array and insert values
for i = 1 : length(input(:,1))
    nlogd2(i) = (logarray(i)^2)*input(i,2);
end

out3 = nlogd2;
end

function out4 = l3(input)
%this calculates the mean value shown on the spreadsheet in cell l3

%call nlndarray
nlogdarray = nlndarray(input);

total = sum(nlogdarray);

out4 = total/(sum(input(:,2)));
end

function out5 = m2(input)
%computes esoteric value form cell m2 of spreadsheet

%call nlnd2
nlogd2 = nlnd2(input);

out5 = (sum(nlogd2))/(sum(input(:,2)));
end

function out6 = n2(input)
%computer equally esoteric value in n2 in spreadsheet

%call nlndarray
nlogdarray = nlndarray(input);

%take ratio of sums
ratio = (sum(nlogdarray))/(sum(input(:,2)));

out6 = ratio^2;
end

function out7 = standev(input)
%calculates interesting standard deviation in l6 in spreadsheet

%call m3
M2 = m2(input);

%call n3
N2 = n2(input);

out7 = sqrt(M2-N2);
end

function out8 = m6(input)
%calculates median from m6 in spreadsheet

%call l3
L3 = l3(input);

out8 = exp(L3);
end