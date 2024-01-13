% script matrix1

% 500MHz - 5GHz
sweeppoints = 100e+6:10e+6:1.5e+9;

% port impedance
Z0 = 50 + 0j

% common functions
addpath("../RFlib")

% tuning cap
cap = 2e-12

ts = sweep2ts(sweeppoints)

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)


    % bandpass tuner, implemented as a capacitively loaded,
    % tapped grounded stub

    % total length of the stub
    len = f2rad(f, 1.5e+9)/4

    % Grounded section
    % terminated with 0.3 ohm (short)
    Mo1 = TLineMatrix(Z0, (len / 2))
    Mo1 = Mo1 * ShuntImpedanceMatrix(0.3)


    % Open-ended section
    % terminated with a tuning cap
    Mo2 = TLineMatrix(Z0, ((len / 2) * 1))
    Mo2 = Mo2 * ShuntImpedanceMatrix(CapacitorImpedance(cap, f) + 0.3)


    % Main line
    M = TLineMatrix(Z0, f2rad(f, 1e+9))
    M = M * OrthogonalNetworkMatrix(Mo1)
    M = M * OrthogonalNetworkMatrix(Mo2)
    M = M * TLineMatrix(Z0, f2rad(f, 1e+9))

    ts.points(fp).ABCD = M
end

plot2ports(ts, 88)

pause()

touchstonewrite([mfilename() '.s2p'], ts)
