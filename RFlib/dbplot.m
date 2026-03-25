% dbplot


function dbplot(S, f, lim, mkr)
    cp = zeros(length(S),1);
    for lp = 1:length(S)
        cp(lp) = gamma2db(S(lp));
    end
    plot(f, cp, "r-", "LineWidth", 2);
    axis(lim);
    grid on;
    if nargin > 3
        str = dbtitle(S(mkr), f(mkr));
        hold on;
        plot(f(mkr), cp(mkr), "bx", "LineWidth", 2);
        % text (f(mkr), cp(mkr), str);
        hold off;
        title(str);
    end
    xlabel("f(Hz)");
end


function str = dbtitle(S, f)
    db = gamma2db(S);
    fs = freq2str(f);
    str = sprintf("%s, %.2f dB", fs, db);
end 

