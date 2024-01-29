% script matrix1

% 100MHz - 5GHz
sweeppoints = 300e+6:5e+6:1.5e+9;

% port impedance
Z0 = 50 + 0j;

% common functions
addpath("../RFlib")

L1 = 11e-9;
L2 = 5e-9;
C = 3.3e-12;

ts = sweep2ts(sweeppoints);

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp);


    % 5th order lowpass filter with fc around 600MHz
    % for Nano-VNA 

    M = ShuntImpedanceMatrix(InductorImpedance(L1, f) + 0.2);
    M = M * SeriesImpedanceMatrix(CapacitorImpedance(C, f) + 0.2);
    M = M * ShuntImpedanceMatrix(InductorImpedance(L2, f) + 0.2);
    M = M * SeriesImpedanceMatrix(CapacitorImpedance(C, f) + 0.2);
    M = M * ShuntImpedanceMatrix(InductorImpedance(L1, f) + 0.2);

    ts.points(fp).ABCD = M;

end

plot2ports(ts, 72);

pause();

touchstonewrite([mfilename() '.s2p'], ts);

