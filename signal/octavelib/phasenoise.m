% script phasenoise

function iq = phasenoise(iq, level)
    for fp = 1:length(iq)

        cm = abs(iq(fp));
        ca = arg(iq(fp));
        noisei = (-0.5 + rand(1)) * level;
        d = cm * (cos(ca + noisei) + j*sin(ca + noisei));
        iq(fp) = d;
    end
end
