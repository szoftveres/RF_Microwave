% touchstoneread

%
% ts.points[P]
%   P.Z
%   P.f
%   P.ABCD(2,2)


function ts = touchstoneread(filename)

    ext = filename(strfind(filename,'.')+1:length(filename));
    ports = str2num(ext(2))

    [fd, rc] = fopen(filename, 'rt');
    if fd == -1
        error(rc);
    end

    ts.points = []

    while true
        line = fgetl(fd)
        if (line < 0 || isempty(line))
            break
        end
        line = strtrim(line)
        if (line(1) == '!')
            continue
        elseif (line(1) == '#')
            line = lower(line)
            % the # character
            [hashmark,line] = strtok(line)
            % freq unit
            [frequnit_str,line] = strtok(line)
            % Type (S, Z, Y)
            [type_str,line] = strtok(line)
            % Format (MA, DB, RI)
            [format_str,line] = strtok(line)
            % R character, and impedance
            [rchar,impedance_str] = strtok(line)
            break;
        end
    end
            
    while true
        line = fgetl(fd)
        if (line < 0 || isempty(line))
            break
        end
        line = strtrim(line)
        P.Z = str2double(impedance_str)
        [P.f, line] = readfreq(line, frequnit_str)
        datapoint = zeros(2)
        % cheating here, trying to avoid division by zero
        datapoint(2,1) = 9e-39
        datapoint(1,2) = 9e-39
        datapoint(2,2) = 9e-39
        [datapoint(1,1), line] = readcomplx(line, format_str)
        if (ports == 2)
            [datapoint(2,1), line] = readcomplx(line, format_str)
            [datapoint(1,2), line] = readcomplx(line, format_str)
            [datapoint(2,2), line] = readcomplx(line, format_str)
        end
        P.ABCD = convertdata(datapoint, type_str, impedance_str)
        ts.points = [ts.points ; P]
    end

end


function [f, line] = readfreq(line, frequnit_str)
    [f_str,line] = strtok(line)
    f = str2double(f_str)
    if strcmp(frequnit_str,'khz')
        f = f * 1e3;
    elseif strcmp(frequnit_str,'mhz')
        f = f * 1e6;
    elseif strcmp(frequnit_str,'ghz')
        f = f * 1e9;
    end
end


function [c, line] = readcomplx(line, format_str)
    [n1, line] = strtok(line)
    [n2, line] = strtok(line)

    if strcmp(format_str,'ri')
        c = str2double(n1) + j * str2double(n2)
    else
        error(format_str)
    end
end

function ABCD = convertdata(M, type_str, impedance_str)
    if strcmp(type_str,'s')
        ABCD = s2abcd(M, str2double(impedance_str))
    else
        error(type_str)
    end
end
