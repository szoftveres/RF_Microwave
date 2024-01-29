% dbplot


function dbplot(S, f, mkr)
    cp = zeros(length(S),1);
    for lp = 1:length(S)
        cp(lp) = gamma2db(S(lp));
    end
    plot(f, cp, "r-", "LineWidth", 2);
    grid on;
    if nargin > 2
        hold on;
        plot(f(mkr), cp(mkr), "bx", "LineWidth", 2);
        hold off;
        dbtitle(S(mkr), f(mkr));
    end
    xlabel("f(Hz)");
end


function dbtitle(S, f)
    db = gamma2db(S);
    fs = freq2str(f);
    str = sprintf("%s, %.2f dB", fs, db);
    title(str);
end 

