function str = z2reactstr(Z, f)
    x = imag(Z)
    if x < 0
        % capacitance
        x = abs(x)
        unit = "F"
        part = Admittance(x) / Omega(f)
    elseif x > 0
        % inductance
        unit = "H"
        part = x / Omega(f)
    else
        str = ""
    end

    fms = ' munpfa'
    fmsp = 1
    while (part * 1000.0) < 1000.0
        part = part * 1000.0
        fmsp = fmsp + 1
    end
    str = sprintf("%.2f%s%s", part, fms(fmsp), unit)
end

