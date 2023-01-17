% script waveguide.m


% 60 - 90GHz 
sweeppoints = 60e+9:.25e+9:90e+9;


function Y = Admittance(Z)
    Y = 1 / Z
end

function O = Omega(F)
    O = 2 * pi * F
end

function M = SeriesImpedanceMatrix(Z)
    M = zeros(2)
    M(1,1) = 1 + 0j
    M(1,2) = Z
    M(2,1) = 0 + 0j
    M(2,2) = 1 + 0j
end

function M = ParallelImpedanceMatrix(Z)
    M = zeros(2)
    M(1,1) = 1 + 0j
    M(1,2) = 0 + 0j
    M(2,1) = Admittance(Z)
    M(2,2) = 1 + 0j
end

function Z = CapacitorImpedance(C, F)
    Z = 0 - (1/(Omega(F) * C))*j
end

function Z = InductorImpedance(L, F)
    Z = 0 + (Omega(F) * L)*j
end

function Z = ParallelImpedance(Z1, Z2)
    Z = 1 / ((1 / Z1) + (1 / Z2))
end

function Z = SeriesImpedance(Z1, Z2)
    Z = Z1 + Z2
end


function M = RectangularWaveguideWidthObstacleMatrix(a1, a2, b, f)
end

function c = LightSpeed()
    c = 299792458
end

function Z = Zfree()
    Mu0 = 4 * pi * 1e-7
    E0 = 1 / (Mu0 * LightSpeed() ^ 2)
    Z = sqrt(Mu0 / E0)
end

function B = RectangularWaveguidePhaseConstant(a, f, emode)
    k0 = Omega(f) / LightSpeed()
    B = sqrt((k0 ^ 2) - (((emode * pi) / a) ^ 2))
end

function Z = RectangularWaveguideWaveImpedance(a, f, emode)
    k0 = Omega(f) / LightSpeed()

    Z = (k0 * Zfree()) / RectangularWaveguidePhaseConstant(a, f, emode)
end


function Z = RectangularWaveguideCharacteristicImpedance(a, b, f)
    Z = RectangularWaveguideWaveImpedance(a, f, 1) * (b / a) * 4
end


function M = RectangularWaveguideTerminationMatrix(a, b, f)
    M = ParallelImpedanceMatrix(RectangularWaveguideCharacteristicImpedance(a, b, f))
end


function M = RectangularWaveguideMatrix(a, b, l, f)
    Zcharacteristic = RectangularWaveguideCharacteristicImpedance(a, b, f)

    BetaZ = RectangularWaveguidePhaseConstant(a, f, 1)

    M = zeros(2)
    M(1,1) = cos(BetaZ * l)
    M(1,2) = sin(BetaZ * l) * Zcharacteristic * j
    M(2,1) = sin(BetaZ * l) * Admittance(Zcharacteristic) * j
    M(2,2) = cos(BetaZ * l)
end


function X = StepReactanceHPlane(a, c, f)
    modes = 1:1:25;
    X = 0

    if (a > c)
        along = a
        ashort = c
    else
        along = c
        ashort = a
    endif

    I = quad(@(x) sin((pi * x)/ashort) * sin((pi * x)/along), 0, ashort, [0.5e-20, 0.5e-20])

    for mode = 1:length(modes)
        ZwaveLong = RectangularWaveguideWaveImpedance(along, f, mode)
        ZwaveShort = RectangularWaveguideWaveImpedance(ashort, f, mode)

        Zloadeff = (4 * ZwaveShort * (I ^ 2)) / (along * ashort)

        A = (Zloadeff - ZwaveLong) / (Zloadeff + ZwaveLong)

        X += ZwaveLong * ((1 + A)/(1 - A)) * j
    end

    if (a > c)
        X *= -1
    endif

end


S11dBplot = []
S21dBplot = []
Z11Smithplot = []
Z11Realplot = []
PhaseConstantPlot = []

for fp = 1:length(sweeppoints)

    f = sweeppoints(fp)

    % WR-12
    a1 = 0.0030989
    b = 0.0015494
    a2 = 0.0015

    portlen = 0.005
    aperturelen = 0.00025
    cavitylen = 0.003


    M = RectangularWaveguideMatrix(a1, b, portlen, f)

    M = M * ParallelImpedanceMatrix(StepReactanceHPlane(a1,a2,f))
    M = M * RectangularWaveguideMatrix(a2, b, aperturelen, f)
    M = M * ParallelImpedanceMatrix(StepReactanceHPlane(a2,a1,f))
    M = M * RectangularWaveguideMatrix(a1, b, cavitylen, f)
    M = M * ParallelImpedanceMatrix(StepReactanceHPlane(a1,a2,f))
    M = M * RectangularWaveguideMatrix(a2, b, aperturelen, f)
    M = M * ParallelImpedanceMatrix(StepReactanceHPlane(a2,a1,f))
    M = M * RectangularWaveguideMatrix(a1, b, cavitylen, f)
    M = M * ParallelImpedanceMatrix(StepReactanceHPlane(a1,a2,f))
    M = M * RectangularWaveguideMatrix(a2, b, aperturelen, f)
    M = M * ParallelImpedanceMatrix(StepReactanceHPlane(a2,a1,f))
    M = M * RectangularWaveguideMatrix(a1, b, cavitylen, f)
    M = M * ParallelImpedanceMatrix(StepReactanceHPlane(a1,a2,f))
    M = M * RectangularWaveguideMatrix(a2, b, aperturelen, f)
    M = M * ParallelImpedanceMatrix(StepReactanceHPlane(a2,a1,f))

    M = M * RectangularWaveguideMatrix(a1, b, portlen, f)

    %M = M * RectangularWaveguideTerminationMatrix(a1, b, f)

    Z0 = RectangularWaveguideCharacteristicImpedance(a1, b, f)

    %Z11 = A/C
    Z11 = (M(1,1)/M(2,1))

    %S11 = (A + B/Z0 - C*Z0 - D) / (A + B/Z0 + C*Z0 + D)
    S11 = (M(1,1) + (M(1,2)/Z0) - (M(2,1)*Z0) - M(2,2)) / (M(1,1) + (M(1,2)/Z0) + (M(2,1)*Z0) + M(2,2))


    %S21 = 2 / (A + B/Z0 + C*Z0 + D)
    S21 = 2 / (M(1,1) + (M(1,2)/Z0) + (M(2,1)*Z0) + M(2,2))
    
    S11dBplot = [S11dBplot; 10*log10(abs(S11))]
    S21dBplot = [S21dBplot; 10*log10(abs(S21))]
    Z11Smithplot = [Z11Smithplot; Z11]
    Z11Realplot = [Z11Realplot; abs(Z11)]
    PhaseConstantPlot = [PhaseConstantPlot; RectangularWaveguidePhaseConstant(a1, f, 1)]

end

fprintf(2, "PI: %.16f\n", pi);
fprintf(2, "Lightspeed: %.2f m/s\n", LightSpeed());
fprintf(2, "Z_freespace: %.6f ohm\n", Zfree());

subplot(2, 2, 1)
plot(sweeppoints, S11dBplot)
title('S1,1 (dB)')
xlabel("f(Hz)");
ylabel("S1,1(dB)");

subplot(2, 2, 2)
plot(sweeppoints, S21dBplot)
title('S2,1 (dB)')
xlabel("f(Hz)");
ylabel("S2,1(dB)");


subplot(2, 2, 3)
plot(sweeppoints, Z11Realplot)
title('Z11 impedance')
xlabel("f(Hz)");
ylabel("Z(ohm)");


subplot(2, 2, 4)
plot(sweeppoints, PhaseConstantPlot)
title('Phase Constant')
xlabel("f(Hz)");
ylabel("Beta(m-1)");

pause()

