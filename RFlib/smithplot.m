% smithplot


function smithplot(cp, format)
    % main circle
    t = linspace(0, 2 * pi, 91);
    plot(cos(t), sin(t), "k-")

    hold on
    % constant circles
    constcircles(0.3333, "k:")
    constcircles(1, "k:")
    constcircles(3, "k:")

    % horizontal line
    t = linspace(-1, 1, 15);
    plot(t, zeros(15), "k-.")
    switch (format)
      case {'S', 's'}
        plotfunc(gplot(cp), "r-", 2)
      case {'Z', 'z'}
        plotfunc(cp, "r-", 2)
      otherwise
        printf("Smith plot format needed\n");
        exit
    end
    ylim([-1, 1])
    hold off
end


function Z = gplot(G)
    Z = []
    for spn = 1:length(G)
        Z = [Z; ((1 + G(spn)) / (1 - G(spn)))]
    end
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


function S = cplxtosmith(cp)
     cr = real(cp)
     ci = imag(cp)

     % converting complex numbers to plot coordinates
     sr = ((cr .^ 2) - 1 + (ci .^ 2)) / (((cr + 1) .^ 2) + (ci .^ 2))
     si = (2 * ci) / (((cr + 1) .^ 2) + (ci .^ 2))

     S = sr + j * si
end


