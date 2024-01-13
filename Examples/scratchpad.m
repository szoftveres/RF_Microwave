% script matrix1

% 500MHz - 1.5GHz
sweeppoints = 500e+6:10e+6:1.5e+9;

% port impedance
Z0 = 50 + 0j

% common functions
addpath("../RFlib")


ts = sweep2ts(sweeppoints)

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    M = SeriesImpedanceMatrix(CapacitorImpedance(3.3e-12, f))

    ts.points(fp).ABCD = M
end

plot2ports(ts, 51)

pause()

