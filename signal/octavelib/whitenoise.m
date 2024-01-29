% script whitenoise

function iq = whitenoise(iq, snrdb)

    noiselevel = 10^(-snrdb/10);
    for fp = 1:length(iq)
        noisem = rand(1) * noiselevel;
        noisea = rand(1) * 2 * pi;
        noisesignal = noisem * (cos(noisea) + j*sin(noisea));
        iq(fp) = iq(fp) + noisesignal;
    end
end
