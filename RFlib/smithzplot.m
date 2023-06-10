% smithzplot

% [cp]
% optional: marker

function smithzplot(cp, mkr)
    % main circle
    t = linspace(0, 2 * pi, 91);
    plot(cos(t), sin(t), "k-")

    hold on
    % constant circles
    constcircles(1/3, "k:")
    constcircles(1, "k:")
    constcircles(3, "k:")

    % horizontal line
    t = linspace(-1, 1, 15);
    plot(t, zeros(15), "k-.")

    % the actual data plot
    plotfunc(cp, "r-", 2)
    xlim([-1, 1])
    ylim([-1, 1])
    if nargin > 1
        markerfunc(cp(mkr))
    end
    hold off
end


function constcircles(n, style)
    base = 3
    a = 1 / base
    b = 0

    step = 11
    for i=1:5
        plotfunc(linspace(b + j * (n), a + j * (n), step), style, 1)
        plotfunc(linspace(b + j * (-n), a + j * (-n), step), style, 1)
        plotfunc(linspace(n + j * (b), n + j * (a), step), style, 1)
        plotfunc(linspace(n + j * (-b), n + j * (-a), step), style, 1)
        b = a
        a = a * base
    end
end


function plotfunc(cp, style, width)
    spr = []
    spi = []
    for spn = 1:length(cp)

        sp = cplxtosmith(cp(spn))

        spr = [spr; real(sp)]
        spi = [spi; imag(sp)]
    end
    plot(spr, spi, style, "LineWidth", width)
end


function markerfunc(cp)
    sp = cplxtosmith(cp)
    plot(real(sp), imag(sp), "bo", "LineWidth", 2)
end


function S = cplxtosmith(cp)
     cr = real(cp)
     ci = imag(cp)

     % converting complex numbers to plot coordinates
     sr = ((cr .^ 2) - 1 + (ci .^ 2)) / (((cr + 1) .^ 2) + (ci .^ 2))
     si = (2 * ci) / (((cr + 1) .^ 2) + (ci .^ 2))

     S = sr + j * si
end


