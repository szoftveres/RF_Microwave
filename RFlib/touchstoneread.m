% touchstoneread

%
% ts.points[P]
%   P.f             frequency
%   P.ABCD(2,2)     ABCD matrix


function ts = touchstoneread(filename)
    % get the ports from the S*P extension
    ext = filename(strfind(filename,'.')+1:length(filename));
    ports = str2num(ext(2));
    if (ports != 1 && ports != 2)
        error("Unsupported port number");
    end

    [fd, rc] = fopen(filename, 'rt');
    if (fd == -1)
        error(rc);
    end

    % skip comment lines
    line = gettouchstoneline(fd);
    if (line < 0 || isempty(line))
        error("empty touchstone file");
    end

    % config line
    if (line(1) == '#')
        % the # character
        [hashmark,line] = strtok(line);
        % freq unit
        [frequnit_str,line] = strtok(line);
        % Type (S, Z, Y)
        [type_str,line] = strtok(line);
        % Format (MA, DB, RI)
        [format_str,line] = strtok(line);
        % R character, and impedance
        [rchar,impedance_str] = strtok(line);
    else
        error("missing # line in touchstone file");
    end

    
    ts.points = [];

    % gather the data
    while true
        line = gettouchstoneline(fd);
        if (line < 0 || isempty(line))
            break;
        end
        [P.f, line] = readfreq(line, frequnit_str);
        datapoint = zeros(2);
        % cheating here, trying to avoid division by zero
        datapoint(2,1) = realmin("single");
        datapoint(1,2) = realmin("single");
        datapoint(2,2) = realmin("single");
        [datapoint(1,1), line] = readcomplx(line, format_str);
        if (ports == 2)
            [datapoint(2,1), line] = readcomplx(line, format_str);
            [datapoint(1,2), line] = readcomplx(line, format_str);
            [datapoint(2,2), line] = readcomplx(line, format_str);
        end
        P.ABCD = convertdata(datapoint, type_str, impedance_str);
        ts.points = [ts.points ; P];
    end
    fclose(fd);
end


function [f, line] = readfreq(line, frequnit_str)
    [f_str,line] = strtok(line);
    f = str2double(f_str);
    if strcmp(frequnit_str,'khz')
        f = f * 1e3;
    elseif strcmp(frequnit_str,'mhz')
        f = f * 1e6;
    elseif strcmp(frequnit_str,'ghz')
        f = f * 1e9;
    end
end


% reads a pair of numbers and converts it to complex n
function [c, line] = readcomplx(line, format_str)
    [n1, line] = strtok(line);
    [n2, line] = strtok(line);

    n1n = str2double(n1);
    n2n = str2double(n2);
    
    if strcmp(format_str,'ri')
        c = n1n + j * n2n;
    elseif strcmp(format_str,'ma')
        c = (n1n * sin(deg2rad(n2n))) + j * (n1n * cos(deg2rad(n2n)));
    elseif strcmp(format_str,'db')
        n1n = 10^(n1n / 20);
        c = (n1n * sin(deg2rad(n2n))) + j * (n1n * cos(deg2rad(n2n)));
    else
        error(format_str);
    end
end


% convert data to ABCD matrix
function ABCD = convertdata(M, type_str, impedance_str)
    if strcmp(type_str,'s')
        ABCD = s2abcd(M, str2double(impedance_str));
    elseif strcmp(type_str,'z')
        ABCD = z2abcd(M);
    elseif strcmp(type_str,'y')
        ABCD = y2abcd(M);
    else
        error(type_str);
    end
end


% Get the nex useful (non-comment) line
function line = gettouchstoneline(fd)
    while true
        line = fgetl(fd);
        if (line < 0 || isempty(line))
            break;
        end
        line = strtrim(line);
        if (line(1) == '!')
            continue;
        end
        line = lower(line);
        break
    end
end


