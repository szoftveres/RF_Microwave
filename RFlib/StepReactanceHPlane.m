
function X = StepReactanceHPlane(a, c, f)
    modes = 1:1:25;
    X = 0;

    if (a > c)
        along = a;
        ashort = c;
    else
        along = c;
        ashort = a;
    endif

    I = quad(@(x) sin((pi * x)/ashort) * sin((pi * x)/along), 0, ashort, [0.5e-20, 0.5e-20]);

    for mode = 1:length(modes)
        ZwaveLong = RectangularWaveguideWaveImpedance(along, f, mode);
        ZwaveShort = RectangularWaveguideWaveImpedance(ashort, f, mode);

        Zloadeff = (4 * ZwaveShort * (I ^ 2)) / (along * ashort);

        A = (Zloadeff - ZwaveLong) / (Zloadeff + ZwaveLong);

        X += ZwaveLong * ((1 + A)/(1 - A)) * j;
    end

    if (a > c)
        X *= -1;
    endif

end

