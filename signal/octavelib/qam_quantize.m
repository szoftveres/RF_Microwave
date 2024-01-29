% script qam_quantize

function iq = qam_quantize(iq, dim)

    for fp = 1:length(iq)
        i = (round(real(iq(fp)) * dim + ((dim - 1) / 2)) - ((dim - 1) / 2)) / dim;
        q = (round(imag(iq(fp)) * dim + ((dim - 1) / 2)) - ((dim - 1) / 2)) / dim;
        iq(fp) = i + (q * j);
    end
end
