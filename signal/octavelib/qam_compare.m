% script qam_compare

function errors = qam_compare(iq1, iq2, dim)

    errors = 0;
    for fp = 1:length(iq1)
        ei = round(real(iq1(fp)) * dim + ((dim - 1) / 2)) - round(real(iq2(fp)) * dim + ((dim - 1) / 2));
        eq = round(imag(iq1(fp)) * dim + ((dim - 1) / 2)) - round(imag(iq2(fp)) * dim + ((dim - 1) / 2));
        if ((ei > 0.01) || (ei < -0.01) || (eq > 0.01) || (eq < -0.01))
            errors = errors + 1;
        end
    end
end
