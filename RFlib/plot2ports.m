% script plot2ports

function plot2ports(ts, mkr)
    
    S11 = []
    S21 = []
    S12 = []
    S22 = []
    f = []

    for a = 1:length(ts.points)
        f = [f; ts.points(a).f]
        Z = ts.points(a).Z
        S11 = [S11; abcd2s(ts.points(a).ABCD, Z)(1,1)]
        S21 = [S21; abcd2s(ts.points(a).ABCD, Z)(2,1)]
        S12 = [S12; abcd2s(ts.points(a).ABCD, Z)(1,2)]
        S22 = [S22; abcd2s(ts.points(a).ABCD, Z)(2,2)]
    end

    subplot(2, 3, 1)
    if nargin > 1
        smithgplot(S11, mkr)
        smithtitle(S11(mkr), f(mkr), ts.points(mkr).Z)
    else
        smithgplot(S11)
    end
    ylabel("S1,1");

    subplot(2, 3, 2)
    if nargin > 1
        dbplot(S11, f, mkr)
    else
        dbplot(S11, f)
    end
    ylabel("S1,1 (dB)");

    subplot(2, 3, 3)
    if nargin > 1
        dbplot(S21, f, mkr)
    else
        dbplot(S21, f)
    end
    ylabel("S2,1 (dB)");

    subplot(2, 3, 4)
    if nargin > 1
        dbplot(S12, f, mkr)
    else
        dbplot(S12, f)
    end
    ylabel("S1,2 (dB)");

    subplot(2, 3, 5)
    if nargin > 1
        dbplot(S22, f, mkr)
    else
        dbplot(S22, f)
    end
    ylabel("S2,2 (dB)");

    subplot(2, 3, 6)
    if nargin > 1
        smithgplot(S22, mkr)
        smithtitle(S22(mkr), f(mkr), ts.points(mkr).Z)
    else
        smithgplot(S22)
    end
    ylabel("S2,2");

end


function smithtitle(S, f, Z0)
    Z = ((1 + S) / (1 - S))
    fs = freq2str(f)
    cps = cplx2str(Z * Z0)
    str = sprintf("%s, %sΩ, %s", fs, cps, z2reactstr(Z * Z0, f))
    title(str)
end

