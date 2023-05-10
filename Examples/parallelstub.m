% script matrix1

% 500MHz - 5GHz
sweeppoints = 500e+6:10e+6:5e+9;

% port impedance
Z0 = 50 + 0j


S11dBplot = []
S21dBplot = []

% common functions
addpath("../ABCDmatrix")

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)


    % 70 ohm 1GHz 1/4 wave orthogonal stub, terminated with 0.3 ohm (short)
    Mo = SeriesImpedanceMatrix(3) % Some simulated loss (3 ohms in series)
    Mo = Mo * TLineMatrix(70, f2rad(f, 1e+9)/4)
    Mo = Mo * ParallelImpedanceMatrix(0.3)

    % Main line
    M = TLineMatrix(Z0, f2rad(f, 1e+9))
    M = M * OrthogonalMatrix(Mo)
    M = M * TLineMatrix(Z0, f2rad(f, 1e+9))

    S = abcd2s(M, Z0)

    S11dBplot = [S11dBplot; 20*log10(abs(S(1,1)))]
    S21dBplot = [S21dBplot; 20*log10(abs(S(2,1)))]

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
