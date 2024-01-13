% script matrix1

% 100MHz - 2000MHz
sweeppoints = 500e+6:10e+6:2000e+6;

% common functions
addpath("../RFlib")

% source 
Z0 = 50
% intermediate Z
Zm = 500
% load 
ZL = 20

% the frequency
Fm = 1e+9

Ql = sqrt((Zm/Z0)-1)
Qr = sqrt((Zm/ZL)-1)

% left inductor
Ll = (Z0*Ql) / Omega(Fm)

% capacitor
Cl = Admittance(Zm/Ql) / Omega(Fm)
Cr = Admittance(Zm/Qr) / Omega(Fm)

% right inductor
Lr = (ZL*Qr) / Omega(Fm)

ts = sweep2ts(sweeppoints)

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % 1/4 wave tline
    
    M = TLineMatrix(Z0, f2rad(f, 1e+9)/4)

    M = M * SeriesImpedanceMatrix(InductorImpedance(Ll, f));
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(Cl + Cr, f));
    M = M * SeriesImpedanceMatrix(InductorImpedance(Lr, f));

    % termination
    M = M * ImpedanceTransformerMatrix(ZL, Z0)

    ts.points(fp).ABCD = M
end

plot2ports(ts, 51)

Ll
Cl + Cr
Lr

pause()

touchstonewrite([mfilename() '.s2p'], ts)

