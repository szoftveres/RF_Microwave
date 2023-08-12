% script matrix1

% 100MHz - 5GHz
sweeppoints = 300e+6:5e+6:1.5e+9;

% port impedance
Z0 = 50 + 0j

% common functions
addpath("../RFlib")


ts = sweep2ts(sweeppoints, Z0)

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)


    M = SeriesImpedanceMatrix(CapacitorImpedance(3.3e-12, f) + 0.2)

    ts.points(fp).ABCD = M

end

plot2ports(ts, 21)

pause()


