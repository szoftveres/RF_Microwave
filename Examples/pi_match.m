% script matrix1

% 100MHz - 2000MHz
sweeppoints = 500e+6:10e+6:2000e+6;

% common functions
addpath("../RFlib")

% source 
Z0 = 50
% intermediate Z
Zm = 5
% load 
ZL = 500

% the frequency
Fm = 1e+9

Ql = sqrt((Z0/Zm)-1)
Qr = sqrt((ZL/Zm)-1)

% capacitor
Cl = Admittance(Z0/Ql) / Omega(Fm)

% inductor
Ll = (Zm*Ql) / Omega(Fm)
Lr = (Zm*Qr) / Omega(Fm)

% capacitor
Cr = Admittance(ZL/Qr) / Omega(Fm)

ts = sweep2ts(sweeppoints)

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % 1/4 wave tline
    
    M = TLineMatrix(Z0, f2rad(f, 1e+9)/4)

    M = M * ShuntImpedanceMatrix(CapacitorImpedance(Cl, f));
    M = M * SeriesImpedanceMatrix(InductorImpedance(Ll + Lr, f));
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(Cr, f));

    % termination
    M = M * ImpedanceTransformerMatrix(ZL, Z0)

    ts.points(fp).ABCD = M
end

plot2ports(ts, 51)

Cl
Ll + Lr
Cr

pause()

touchstonewrite([mfilename() '.s2p'], ts)

