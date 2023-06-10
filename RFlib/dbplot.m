% dbplot


function dbplot(S, f, mkr)
    cp = []
    for lp = 1:length(S)
        cp = [cp; 20*log10(abs(S(lp)))]
    end
    plot(f, cp, "r-", "LineWidth", 2)
    grid on
    if nargin > 2
        hold on
        plot(f(mkr), cp(mkr), "bx", "LineWidth", 2)
        hold off
    end
    xlabel("f(Hz)");
end



