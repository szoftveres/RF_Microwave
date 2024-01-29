% touchstonewrite

%
% ts.points[P]
%   P.f             frequency
%   P.ABCD(2,2)     ABCD matrix


function touchstonewrite(filename, ts)

    [fd, rc] = fopen(filename, 'w');
    if (fd == -1)
        error(rc);
    end
    Z0 = 50;

    fprintf(fd, "! https://github.com/szoftveres \n");
    fprintf(fd, "# Hz S RI R 50\n");

    for i = 1:length(ts.points)
        % write the frequency
        fprintf(fd, "%.1f\t", ts.points(i).f);

        writecomplxri(fd, abcd2s(ts.points(i).ABCD, Z0)(1,1));
        writecomplxri(fd, abcd2s(ts.points(i).ABCD, Z0)(2,1));
        writecomplxri(fd, abcd2s(ts.points(i).ABCD, Z0)(1,2));
        writecomplxri(fd, abcd2s(ts.points(i).ABCD, Z0)(2,2));

        fprintf(fd, "\n");
    end
    fclose(fd);
end


% write complex number in RI format
function writecomplxri(fd, c)
    
    fprintf(fd, "%.8f\t", real(c));
    fprintf(fd, "%.8f\t", imag(c));
end


