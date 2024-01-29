function str = cplx2str(cp)
    cpi = imag(cp);
    signs = "+";
    if cpi < 0
        cpi = abs(cpi);
        signs = "-";
    end
    str = sprintf("%.2f%sj%.2f", real(cp), signs, cpi);
end 

