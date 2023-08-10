% script matrix1

% 500MHz - 5GHz
sweeppoints = 500e+6:10e+6:5e+9;

% port impedance
Z0 = 50 + 0j

% common functions
addpath("../RFlib")

ts = sweep2ts(sweeppoints, Z0)

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)


    % 70 ohm 1GHz 1/4 wave orthogonal stub, terminated with 0.3 ohm (short)
    Mo = SeriesImpedanceMatrix(3) % Some simulated loss (3 ohms in series)
    Mo = Mo * TLineMatrix(70, f2rad(f, 1e+9)/4)
    Mo = Mo * ShuntImpedanceMatrix(0.3)

    % Main line
    M = TLineMatrix(Z0, f2rad(f, 1e+9))
    M = M * OrthogonalNetworkMatrix(Mo)
    M = M * TLineMatrix(Z0, f2rad(f, 1e+9))

    ts.points(fp).ABCD = M    

end

plot2ports(ts, 51)

pause()
