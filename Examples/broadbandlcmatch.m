% script matrix1

% 100MHz - 2000MHz
sweeppoints = 500e+6:10e+6:1500e+6;


% common functions
addpath("../RFlib")

% === Input parameters ====

% source
Z0 = 50
% load
ZL = 2500
% the frequency
Fm = 1e+9

% ===============

% intermediate impedance
ZM = sqrt(Z0 * ZL)

% Q = sqrt((ZL/Z0)-1)
Q1 = sqrt((ZM/Z0)-1)
Q2 = sqrt((ZL/ZM)-1)

%Kf = sqrt((Z0/ZM) * Q1^2)
Kf = sqrt((Z0/ZM) * (ZM/Z0 - 1))
% Correcting the frequency for the second peak
Fm = Fm * Kf

% inductor
L1 = (Z0*Q1) / Omega(Fm)
L2 = (ZM*Q2) / Omega(Fm)

% capacitor
C1 = Admittance(ZM/Q1) / Omega(Fm)
C2 = Admittance(ZL/Q2) / Omega(Fm)

f1 = 1 / (2 * pi * sqrt(L1 * C1))
f2 = 1 / (2 * pi * sqrt(L2 * C2))

ts = sweep2ts(sweeppoints)

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % 1/4 wave tline
    
    M = TLineMatrix(Z0, f2rad(f, 1e+9)/4)

    M = M * SeriesImpedanceMatrix(InductorImpedance(L1, f));
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(C1, f));

    M = M * SeriesImpedanceMatrix(InductorImpedance(L2, f));
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(C2, f));

    M = M * ImpedanceTransformerMatrix(ZL, Z0)

    ts.points(fp).ABCD = M
end

plot2ports(ts, 51)

pause()

touchstonewrite([mfilename() '.s2p'], ts)

L1
C1
L2
C2
Q1
Q2

