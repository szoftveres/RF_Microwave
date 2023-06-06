% smithplot


function smithplot(cp)

    % main circle
    t = linspace(0, 2 * pi, 151);
    x = cos(t)
    y = sin(t)
    plot(x, y, "k-")

    % constant real part circles
    hold on
    k = [0.25 0.5 0.75]'
    x1 = k + (1 - k) * cos(t)
    y1 = (1 - k) * sin(t)
    plot(x1', y1', "k--")

    % constant imaginary part circles
    kt = [2.5 pi 3.79]
    k = [.5 1 2]
    for i = 1:length(kt)
        t = linspace(kt(i), 1.5 * pi, 151)
        a = 1 + k(i) * cos(t)
        b = k(i) + k(i) * sin(t)
        plot(a, b, "k--")
        plot(a, -b, "k--")
    end

    % horizontal line
    t = linspace(-1, 1, 15);
    plot(t, zeros(15), "k--")

    % converting complex numbers to plot coordinates
    spr = []
    spi = []
    for spn = 1:length(cp)

        % converting reflection coefficient to impdance
        zpn = ((1 + cp(spn)) / (1 - cp(spn)))

        cr = real(zpn)
        ci = imag(zpn)

        greal = ((cr ^ 2) - 1 + (ci ^ 2)) / (((cr + 1) ^ 2) + (ci ^ 2))
        gimag = (2 * ci) / (((cr + 1) ^ 2) + (ci ^ 2))
        spr = [spr; greal]
        spi = [spi; gimag]
    end
    plot(spr, spi, "r-", "LineWidth", 2)

    ylim([-1, 1])
    hold off
end


    % Admittance
    %x1 = k + k * cos(t) - 1
    %y1 = k * sin(t)
    %    a = 1 - (2 + k(i) * cos(t))
    %    b = k(i) + k(i) * sin(t)



