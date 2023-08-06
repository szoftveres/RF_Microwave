% script matrix1

% 500MHz - 1.5GHz
sweeppoints = 900e+6:2e+6:1100e+6;

% port impedance
Z0 = 50 + 0j


S11realplot = []
S11imagplot = []
S11plot = []
Z11realplot = []
Z11imagplot = []
Y11realplot = []
Y11imagplot = []

% common functions
addpath("../RFlib")


for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % First, we need to find a series transmission line length that
    % brings Y1,1(real) to 0.02 (1/50ohm); then find a parallel
    % stub that resonates out the remaining reactance
    
    % The parallel stub
    Mo = TLineMatrix(Z0, (f2rad(f, 1.0e+9)) * 0.58)
    Mo = Mo * ShuntImpedanceMatrix(3e12)

    % The full network
    M = OrthogonalNetworkMatrix(Mo)
    M = M * TLineMatrix(Z0, (f2rad(f, 1.0e+9)) * 0.14)
    M = M * SeriesImpedanceMatrix(29.76)
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(20.793e-12, f))

    % Isolation from Port2
    M = M * SeriesImpedanceMatrix(3e12)

    S = abcd2s(M, Z0)
    Z = abcd2z(M)
    Y = abcd2y(M)

    S11realplot = [S11realplot; real(S(1,1))]
    S11imagplot = [S11imagplot; imag(S(1,1))]
    S11plot     = [S11plot; S(1,1)]
    Z11realplot = [Z11realplot; real(Z(1,1))]
    Z11imagplot = [Z11imagplot; imag(Z(1,1))]
    Y11realplot = [Y11realplot; real(Y(1,1))]
    Y11imagplot = [Y11imagplot; imag(Y(1,1))]

end

subplot(3, 3, 1)
dbplot(S11plot, sweeppoints)
xlabel("f(Hz)");
ylabel("S1,1(dB)");

subplot(3, 3, 2)
plot(sweeppoints, S11realplot)
xlabel("f(Hz)");
ylabel("S1,1 real");

subplot(3, 3, 3)
plot(sweeppoints, S11imagplot)
xlabel("f(Hz)");
ylabel("S1,1 imag");

subplot(3, 3, 4)
smithgplot(S11plot)
ylabel("S1,1");


subplot(3, 3, 5)
plot(sweeppoints, Z11realplot)
xlabel("f(Hz)");
ylabel("Z1,1 real (ohm)");

subplot(3, 3, 6)
plot(sweeppoints, Z11imagplot)
xlabel("f(Hz)");
ylabel("Z1,1 imag (ohm)");

subplot(3, 3, 8)
plot(sweeppoints, Y11realplot)
xlabel("f(Hz)");
ylabel("Y1,1 real (mho)");

subplot(3, 3, 9)
plot(sweeppoints, Y11imagplot)
xlabel("f(Hz)");
ylabel("Y1,1 imag (mho)");

pause()
