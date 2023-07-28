% script matrix1

% 100MHz - 2000MHz
sweeppoints = 500e+6:10e+6:2000e+6;


% common functions
addpath("../RFlib")


% source
Z0 = 50
% load
ZL = 500

Q = sqrt((ZL/Z0)-1)

% the frequency
Fm = 1e+9

% inductor
L = (Z0*Q) / Omega(Fm)

% capacitor
C = Admittance(ZL/Q) / Omega(Fm)


S11complexplot = []
S11dBplot = []


for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % 1/4 wave tline
    
    M = TLineMatrix(Z0, f2rad(f, 1e+9)/4)

    M = M * SeriesImpedanceMatrix(InductorImpedance(L, f));
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(C, f));

    % termination
    M = M * ShuntImpedanceMatrix(500.0)
    % isolation from port 2
    M = M * SeriesImpedanceMatrix(9e+9)



    S = abcd2s(M, Z0)


    S11dBplot = [S11dBplot; gamma2db(S(1,1))]
    S11complexplot = [S11complexplot; S(1,1)]

end

subplot(1, 2, 1)
plot(sweeppoints, S11dBplot)
xlabel("f(Hz)");
ylabel("S1,1(dB)");

subplot(1, 2, 2)
smithgplot(S11complexplot)
ylabel("S1,1");

L
C

pause()


