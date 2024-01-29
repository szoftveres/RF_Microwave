% script matrix1

% 100MHz - 2000MHz
sweeppoints = 500e+6:10e+6:2000e+6;


% common functions
addpath("../RFlib")


% source
Z0 = 50;
% load
ZL = 100;

Q = sqrt((ZL/Z0)-1);

% the frequency
Fm = 1e+9;

% inductor
L = (Z0*Q) / Omega(Fm);

% capacitor
C = Admittance(ZL/Q) / Omega(Fm);

ts = sweep2ts(sweeppoints);

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp);

    % 1/4 wave tline
    
    M = TLineMatrix(Z0, f2rad(f, 1e+9)/4);

    M = M * SeriesImpedanceMatrix(InductorImpedance(L, f));
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(C, f));

    % termination
    M = M * ImpedanceTransformerMatrix(ZL, Z0);

    ts.points(fp).ABCD = M;

end

plot2ports(ts, 51);
touchstonewrite([mfilename() '.s2p'], ts);

L
C

pause();


