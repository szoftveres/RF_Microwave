function str = freq2str(f)
    fms =' kMGT';
    fmsp = 1;
    while (f / 1000.0) > 1.0
        f = f / 1000.0;
        fmsp = fmsp + 1;
    end
    str = sprintf("%.2f %sHz", f, fms(fmsp));
end

