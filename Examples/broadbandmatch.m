% script matrix1

% 100MHz - 2000MHz
sweeppoints = 100e+6:10e+6:2000e+6;

% port impedance
Z0 = 50 + 0j


S11dBplot = []
Z11Magplot = []

% common functions
addpath("../RFlib")

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % 1/4 wave tline
    M = TLineMatrix(40.89, f2rad(f, 1e+9)/4)
    M = M * TLineMatrix(33.44, f2rad(f, 1e+9)/4)
    M = M * TLineMatrix(27.34, f2rad(f, 1e+9)/4)
    M = M * TLineMatrix(22.36, f2rad(f, 1e+9)/4)
    M = M * TLineMatrix(18.28, f2rad(f, 1e+9)/4)
    M = M * TLineMatrix(14.95, f2rad(f, 1e+9)/4)
    M = M * TLineMatrix(12.23, f2rad(f, 1e+9)/4)

    % 10 ohms
    M = M * ShuntImpedanceMatrix(10.0)


    %Z11 = A/C
    Z11 = M(1,1)/M(2,1) 

    S = abcd2s(M, Z0)


    % S2,1 magnitude in dB
    S11dBplot = [S11dBplot; 20*log10(abs(S(1,1)))]
    
    % Z1,1 in ohms
    Z11Magplot = [Z11Magplot; abs(Z11)]

end

subplot(2, 1, 1)
plot(sweeppoints, S11dBplot)
xlabel("f(Hz)");
ylabel("S1,1(dB)");

subplot(2, 1, 2)
plot(sweeppoints, Z11Magplot)
xlabel("f(Hz)");
ylabel("Z1,1(ohm)");
pause()
