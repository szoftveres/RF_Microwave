% script waveguide.m


% 60 - 90GHz 
sweeppoints = 60e+9:.25e+9:90e+9;

% common functions
addpath("../RFlib")


S11plot = []
S21plot = []
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

    M = M * ShuntImpedanceMatrix(StepReactanceHPlane(a1,a2,f))
    M = M * RectangularWaveguideMatrix(a2, b, aperturelen, f)
    M = M * ShuntImpedanceMatrix(StepReactanceHPlane(a2,a1,f))
    M = M * RectangularWaveguideMatrix(a1, b, cavitylen, f)
    M = M * ShuntImpedanceMatrix(StepReactanceHPlane(a1,a2,f))
    M = M * RectangularWaveguideMatrix(a2, b, aperturelen, f)
    M = M * ShuntImpedanceMatrix(StepReactanceHPlane(a2,a1,f))
    M = M * RectangularWaveguideMatrix(a1, b, cavitylen, f)
    M = M * ShuntImpedanceMatrix(StepReactanceHPlane(a1,a2,f))
    M = M * RectangularWaveguideMatrix(a2, b, aperturelen, f)
    M = M * ShuntImpedanceMatrix(StepReactanceHPlane(a2,a1,f))
    M = M * RectangularWaveguideMatrix(a1, b, cavitylen, f)
    M = M * ShuntImpedanceMatrix(StepReactanceHPlane(a1,a2,f))
    M = M * RectangularWaveguideMatrix(a2, b, aperturelen, f)
    M = M * ShuntImpedanceMatrix(StepReactanceHPlane(a2,a1,f))

    M = M * RectangularWaveguideMatrix(a1, b, portlen, f)

    %M = M * RectangularWaveguideTerminationMatrix(a1, b, f)

    Z0 = RectangularWaveguideCharacteristicImpedance(a1, b, f)

    %Z11 = A/C
    Z11 = (M(1,1)/M(2,1))

    S = abcd2s(M, Z0)
 
    S11plot = [S11plot; S(1,1)]
    S21plot = [S21plot; S(2,1)]
    Z11Realplot = [Z11Realplot; abs(Z11)]
    PhaseConstantPlot = [PhaseConstantPlot; RectangularWaveguidePhaseConstant(a1, f, 1)]

end

fprintf(2, "PI: %.16f\n", pi);
fprintf(2, "Lightspeed: %.2f m/s\n", LightSpeed());
fprintf(2, "Z_freespace: %.6f ohm\n", Zfree());

subplot(2, 2, 1)
dbplot(S11plot, sweeppoints)
title('S1,1 (dB)')
xlabel("f(Hz)");
ylabel("S1,1(dB)");

subplot(2, 2, 2)
dbplot(S21plot, sweeppoints)
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

