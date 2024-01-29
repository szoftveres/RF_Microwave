% script matrix1

% 900MHz - 1.1GHz
sweeppoints = 950e+6:1e+6:1050e+6;

% port impedance
Z0 = 50 + 0j;


S11plot = [];
Z11plot = [];

% common functions
addpath("../RFlib")

% Charactarestic impedance of the patch
Zt = 6;

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp);


    % patch antenna impedance simulation for best coupling

    % two, unequal length, very low impedance transmission lines
    % with a combined length of 1/2 wave for the desired frequency

    % 1/2 wavelength at 1GHz
    len = f2rad(f, 1.0e+9) / 2;

    % Shorter section
    Mo1 = TLineMatrix(Zt, (len * 0.51));
    Mo1 = Mo1 * ShuntImpedanceMatrix(3e4);


    % Shorter section
    Mo2 = TLineMatrix(Zt, (len * 0.49));
    Mo2 = Mo2 * ShuntImpedanceMatrix(3e4);


    % Main line
    M = OrthogonalNetworkMatrix(Mo1);
    M = M * OrthogonalNetworkMatrix(Mo2);

    % isolation from port2
    M = M * SeriesImpedanceMatrix(3e12);

    S = abcd2s(M, Z0);
    Z = abcd2z(M);

    S11plot = [S11plot; S(1,1)];
    Z11plot = [Z11plot; abs(Z(1,1))];

end

subplot(2, 2, 1);
dbplot(S11plot, sweeppoints);
xlabel("f(Hz)");
ylabel("S1,1(dB)");

subplot(2, 2, 2);
plot(sweeppoints, Z11plot);
xlabel("f(Hz)");
ylabel("Z1,1(ohm)");

pause();


