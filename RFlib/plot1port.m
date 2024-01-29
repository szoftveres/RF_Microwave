% script plot1port

function plot1port(ts, mkr)
    
    S11 = zeros(length(ts.points),1);
    f = zeros(length(ts.points),1);
    Z = 50;

    for a = 1:length(ts.points)
        f(a) = ts.points(a).f;
        S11(a) = abcd2s(ts.points(a).ABCD, Z)(1,1);
    end

    subplot(1, 2, 1);
    if nargin > 1
        smithgplot(S11, mkr);
        smithtitle(S11(mkr), f(mkr), Z);
    else
        smithgplot(S11);
    end
    ylabel("S1,1");

    subplot(1, 2, 2);
    if nargin > 1
        dbplot(S11, f, mkr);
    else
        dbplot(S11, f);
    end
    ylabel("S1,1 (dB)");

end


function smithtitle(S, f, Z0)
    Z = ((1 + S) / (1 - S));
    fs = freq2str(f);
    cps = cplx2str(Z * Z0);
    str = sprintf("%s, %sΩ, %s", fs, cps, z2reactstr(Z * Z0, f));
    title(str);
end

