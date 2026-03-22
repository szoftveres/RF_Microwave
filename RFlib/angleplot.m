% angleplot


function angleplot(S, f, mkr)
    lim = [f(1) f(length(f)) -180, 180];
    cp = zeros(length(S),1);
    for lp = 1:length(S)
        cp(lp) = angle(S(lp)) / pi * 180;
    end
    plot(f, cp, "r-", "LineWidth", 2);
    axis(lim);
    grid on;
    if nargin > 2
        hold on;
        plot(f(mkr), cp(mkr), "bx", "LineWidth", 2);
        hold off;
        angletitle(S(mkr), f(mkr));
    end
    xlabel("f(Hz)");
end


function angletitle(S, f)
    deg = angle(S) / pi * 180;
    fs = freq2str(f);
    str = sprintf("%s, %.2f°", fs, deg);
    title(str);
end 

