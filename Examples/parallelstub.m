% script matrix1

% 500MHz - 5GHz
sweeppoints = 500e+6:10e+6:5e+9;

% port impedance
Z0 = 50 + 0j


S11plot = []
S21plot = []

% common functions
addpath("../RFlib")

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)


    % 70 ohm 1GHz 1/4 wave orthogonal stub, terminated with 0.3 ohm (short)
    Mo = SeriesImpedanceMatrix(3) % Some simulated loss (3 ohms in series)
    Mo = Mo * TLineMatrix(70, f2rad(f, 1e+9)/4)
    Mo = Mo * ShuntImpedanceMatrix(0.3)

    % Main line
    M = TLineMatrix(Z0, f2rad(f, 1e+9))
    M = M * OrthogonalNetworkMatrix(Mo)
    M = M * TLineMatrix(Z0, f2rad(f, 1e+9))

    S = abcd2s(M, Z0)

    S11plot = [S11plot; S(1,1)]
    S21plot = [S21plot; S(2,1)]

end

subplot(2, 2, 1)
dbplot(S11plot, sweeppoints)
xlabel("f(Hz)");
ylabel("S1,1(dB)");

subplot(2, 2, 2)
dbplot(S21plot, sweeppoints)
xlabel("f(Hz)");
ylabel("S2,1(dB)");

pause()
