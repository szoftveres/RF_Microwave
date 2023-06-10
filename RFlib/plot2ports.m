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
        smithtitle(S11(mkr), f(mkr))
    else
        smithgplot(S11)
    end
    ylabel("S1,1");

    subplot(2, 3, 2)
    if nargin > 1
        dbplot(S11, f, mkr)
        dbtitle(S11(mkr), f(mkr))
    else
        dbplot(S11, f)
    end
    ylabel("S1,1");

    subplot(2, 3, 3)
    if nargin > 1
        dbplot(S21, f, mkr)
        dbtitle(S21(mkr), f(mkr))
    else
        dbplot(S21, f)
    end
    ylabel("S2,1");

    subplot(2, 3, 4)
    if nargin > 1
        dbplot(S12, f, mkr)
        dbtitle(S12(mkr), f(mkr))
    else
        dbplot(S12, f)
    end
    ylabel("S1,2");

    subplot(2, 3, 5)
    if nargin > 1
        dbplot(S22, f, mkr)
        dbtitle(S22(mkr), f(mkr))
    else
        dbplot(S22, f)
    end
    ylabel("S2,2");

    subplot(2, 3, 6)
    if nargin > 1
        smithgplot(S22, mkr)
        smithtitle(S22(mkr), f(mkr))
    else
        smithgplot(S22)
    end
    ylabel("S2,2");

end


function dbtitle(S, f)
    db = 20*log10(abs(S))
    fs = freq2str(f)
    str = sprintf("%s, %.2f dB", fs, db)
    title(str)
end


function smithtitle(S, f)
    Z = ((1 + S) / (1 - S))
    fs = freq2str(f)
    cps = cplx2str(Z)
    str = sprintf("%s, %s", fs, cps)
    title(str)
end


function str = cplx2str(cp)
    cpi = imag(cp)
    if cpi < 0
        str = sprintf("%.2f - i%.2f", real(cp), abs(cpi))
    else
        str = sprintf("%.2f + i%.2f", real(cp), cpi)
    end
end


function str = freq2str(f)
    fms =' kMGT'
    fmsp = 1
    while (f / 1000.0) > 1.0
        f = f / 1000.0
        fmsp = fmsp + 1
    end
    str = sprintf("%.2f %sHz", f, fms(fmsp))
end

