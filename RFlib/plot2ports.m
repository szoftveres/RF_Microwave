% script plot2ports

function plot2ports(ts, mkr)
   
    lim_refl = [ts.points(1).f ts.points(length(ts.points)).f -80, 5];
    lim_thru = [ts.points(1).f ts.points(length(ts.points)).f -40, 30];
 
    S11 = zeros(length(ts.points),1);
    S21 = zeros(length(ts.points),1);
    S12 = zeros(length(ts.points),1);
    S22 = zeros(length(ts.points),1);
    f = zeros(length(ts.points),1);
    Z = 50;

    for a = 1:length(ts.points)
        f(a) = ts.points(a).f;
        S11(a) = ts.points(a).S(1,1);
        S21(a) = ts.points(a).S(2,1);
        S12(a) = ts.points(a).S(1,2);
        S22(a) = ts.points(a).S(2,2);
    end

    subplot(2, 3, 1);
    if nargin > 1
        smithgplot(S11, mkr);
        smithtitle(S11(mkr), f(mkr), Z);
    else
        smithgplot(S11);
    end
    ylabel("S1,1");

    subplot(2, 3, 2)
    if nargin > 1
        dbplot(S11, f, lim_refl, mkr);
    else
        dbplot(S11, f, lim_refl);
    end
    ylabel("S1,1 (dB)");

    subplot(2, 3, 3)
    if nargin > 1
        dbplot(S21, f, lim_thru, mkr);
    else
        dbplot(S21, f, lim_thru);
    end
    ylabel("S2,1 (dB)");

    subplot(2, 3, 4);
    if nargin > 1
        dbplot(S12, f, lim_thru, mkr);
    else
        dbplot(S12, f, lim_thru);
    end
    ylabel("S1,2 (dB)");

    subplot(2, 3, 5);
    if nargin > 1
        dbplot(S22, f, lim_refl, mkr);
    else
        dbplot(S22, f, lim_refl);
    end
    ylabel("S2,2 (dB)");

    subplot(2, 3, 6);
    if nargin > 1
        smithgplot(S22, mkr);
        smithtitle(S22(mkr), f(mkr), Z);
    else
        smithgplot(S22);
    end
    ylabel("S2,2");

end


function smithtitle(S, f, Z0)
    Z = ((1 + S) / (1 - S));
    fs = freq2str(f);
    cps = cplx2str(Z * Z0);
    str = sprintf("%s, %sΩ, %s", fs, cps, z2reactstr(Z * Z0, f));
    title(str);
end

