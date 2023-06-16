% script matrix1

% 500MHz - 5GHz
sweeppoints = 100e+6:10e+6:1.5e+9;

% port impedance
Z0 = 50 + 0j


S11dBplot = []
S21dBplot = []

% common functions
addpath("../RFlib")

% tuning cap
cap = 2e-12

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)


    % bandpass tuner, implemented as a capacitively loaded,
    % tapped grounded stub

    % total length of the stub
    len = f2rad(f, 1.5e+9)/4

    % Grounded section
    % terminated with 0.3 ohm (short)
    Mo1 = TLineMatrix(Z0, (len / 2))
    Mo1 = Mo1 * ShuntImpedanceMatrix(0.3)


    % Open-ended section
    % terminated with a tuning cap
    Mo2 = TLineMatrix(Z0, ((len / 2) * 1))
    Mo2 = Mo2 * ShuntImpedanceMatrix(CapacitorImpedance(cap, f) + 0.3)


    % Main line
    M = TLineMatrix(Z0, f2rad(f, 1e+9))
    M = M * OrthogonalNetworkMatrix(Mo1)
    M = M * OrthogonalNetworkMatrix(Mo2)
    M = M * TLineMatrix(Z0, f2rad(f, 1e+9))

    S = abcd2s(M, Z0)

    S11dBplot = [S11dBplot; gamma2db(S(1,1))]
    S21dBplot = [S21dBplot; gamma2db(S(2,1))]

end

subplot(2, 2, 1)
plot(sweeppoints, S11dBplot)
xlabel("f(Hz)");
ylabel("S1,1(dB)");

subplot(2, 2, 2)
plot(sweeppoints, S21dBplot)
xlabel("f(Hz)");
ylabel("S2,1(dB)");

pause()
