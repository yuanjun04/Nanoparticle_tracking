function output = nextday (day)

year = str2double(day(1:4));
month = str2double(day(5:6));
date = str2double(day(7:8));
%months with 31 days
if or(or(or(or(month == 01,month == 03),or(month == 05,month == 07)),or(month ==08,month==10)),month==12)
    if date < 31
        date = date + 1;
        output = strcat(num2str(year),num2str(month),num2str(date));
        return
    else
        date = 01;
        if month == 12
            year = year + 1;
            month = 01;
            output = strcat(num2str(year),num2str(month),num2str(date));
            return
        else
            month = month + 1;
            output = strcat(num2str(year),num2str(month),num2str(date));
            return
        end
    end
end
            
end


while nextday(day) < 20150305
    address = strcat('wget http://static.schlockmercenary.com/comics/schlock',num2str(day),'.png');
    FID = fopen('script.sh','w');
    fprintf(FID,address);
    fclose(FID);
    !sh script.sh
    address = strcat('wget http://static.schlockmercenary.com/comics/schlock',num2str(day),'.jpg');
    FID = fopen('script.sh','w');
    fprintf(FID,address);
    fclose(FID);
    !sh script.sh
end
