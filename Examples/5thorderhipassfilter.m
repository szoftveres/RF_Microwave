% script matrix1

% 100MHz - 5GHz
sweeppoints = 300e+6:5e+6:1.5e+9;

% port impedance
Z0 = 50 + 0j


S11plot = []
S21plot = []

% common functions
addpath("../RFlib")

L1 = 11e-9
L2 = 5e-9
C = 3.3e-12

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)


    % 5th order lowpass filter with fc around 600MHz
    % for Nano-VNA 

    M = ShuntImpedanceMatrix(InductorImpedance(L1, f) + 0.2)
    M = M * SeriesImpedanceMatrix(CapacitorImpedance(C, f) + 0.2)
    M = M * ShuntImpedanceMatrix(InductorImpedance(L2, f) + 0.2)
    M = M * SeriesImpedanceMatrix(CapacitorImpedance(C, f) + 0.2)
    M = M * ShuntImpedanceMatrix(InductorImpedance(L1, f) + 0.2)

    S = abcd2s(M, Z0)

    S11plot = [S11plot; S(1,1)]
    S21plot = [S21plot; S(2,1)]

end

subplot(2, 2, 1)
dbplot(S11plot, sweeppoints)
xlabel("f(Hz)");
ylabel("S1,1(dB)");

subplot(2, 2, 2)
dbplot(S11plot, sweeppoints)
xlabel("f(Hz)");
ylabel("S2,1(dB)");

pause()


