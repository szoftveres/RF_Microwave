% script qamplot

function qamplot(iq, dim)

    ri = zeros(length(iq),1);
    rq = zeros(length(iq),1);
    for fp = 1:length(iq)
        ri(fp) = real(iq(fp));
        rq(fp) = imag(iq(fp));
    end

    ticks = 0:dim;
    ticks = ((ticks - ((dim - 1) / 2)) / dim) + (1/dim/2);

    plot(ri, rq, "b.", "LineWidth", 3);
    xticks(ticks);
    yticks(ticks);
    axis([(-0.5) (0.5) (-0.5) (0.5)]);
    grid on;

end
