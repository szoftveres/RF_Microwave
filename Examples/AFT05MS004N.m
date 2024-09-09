%
% Small-signal matching of the AFT05MS004N MOSFET PA at 915 MHz
%
% Input is high-pass L-match, and 220ohm degeneration for stability
% Output is dual low-pass L-match
%

% port impedance
Z0 = 50;

% common functions
addpath("../RFlib")

transistor = touchstoneread('AFT05MS004N_SP.s2p');
ts = transistor;

for fp = 1:length(ts.points)
    f = ts.points(fp).f;

    M = ShuntImpedanceMatrix(9e19); % Initial BS

    % L input match, DC block (also blocking lower frequenies)
    M = M * SeriesImpedanceMatrix(CapacitorImpedance(2.2e-12, f));
    
    % L input match
    M = M * ShuntImpedanceMatrix(InductorImpedance(6.3e-9, f));

    % Input shunt degeneration for stability (also DC bias)
    M = M * ShuntImpedanceMatrix(220.0);

    % The transistor S-parameter block
    M = M * transistor.points(fp).ABCD;

    % load inductor (Vdd supply)
    M = M * ShuntImpedanceMatrix(InductorImpedance(47.0e-9, f));

    % DC block (also blocks lower frequencies)
    M = M * SeriesImpedanceMatrix(CapacitorImpedance(47e-12, f));

    % This resonates out the output impedance to real value (~2.2ohm)
    M = M * SeriesImpedanceMatrix(InductorImpedance(10.883e-9, f));

    % Dual, broadband low-pass L-match
    M = M * SeriesImpedanceMatrix(InductorImpedance(0.72e-9, f));
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(32.75e-12, f));

    M = M * SeriesImpedanceMatrix(InductorImpedance(3.48e-9, f));
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(6.96e-12, f));

    S = abcd2s(M, Z0);
    f
    K = rollet(S)
    gamma = conjmatch(S(1,1), S(2,2), S)

    ts.points(fp).ABCD = M;
end


plot2ports(ts, 164)


pause()


