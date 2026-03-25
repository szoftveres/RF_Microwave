% script matrix1

% port impedance
Z0 = 50 + 0j;

% common functions
addpath("../RFlib")


tsm = touchstoneread('offsetshort.s2p');

tso = touchstoneread('opencal.s2p');
tsos = touchstoneread('offsetshortcal.s2p');
tss = touchstoneread('shortcal.s2p');
tsl = touchstoneread('loadcal.s2p');

ts = tsm;

%%%%%%%%%%%%%%%%%%%%%%%%%
% OPEN, SHORT, LOAD

for fp = 1:length(ts.points)
    f = ts.points(fp).f;
    Sm = tsm.points(fp).S(1,1);

    So = tso.points(fp).S(1,1);
    Ss = tss.points(fp).S(1,1);
    Sl = tsl.points(fp).S(1,1);
    S = zeros(2);
    S(1,1) = p1cal(Sm, So, Ss, Sl, 1, -1, 0);
    S(2,1) = 1;
    S(1,2) = 1;
    S(2,2) = 0;

    ts.points(fp).S = S;

end

plot1port(ts, 64);

pause();

%%%%%%%%%%%%%%%%%%%%%%%%%
% OFFSET SHORT, SHORT, LOAD

for fp = 1:length(ts.points)
    f = ts.points(fp).f;
    Sm = tsm.points(fp).S(1,1);

    % Building an offset short model
    Mosmodel = TLineMatrix(Z0, f2rad(f, 161.2e+6) / 4);
    Mosmodel = Mosmodel * ShuntImpedanceMatrix(1e-9);
    Mosmodel = Mosmodel * SeriesImpedanceMatrix(9e9);
    Sosmodel = abcd2s(Mosmodel, Z0);
    Gosmodel = Sosmodel(1,1);

    Sos = tsos.points(fp).S(1,1);
    Ss = tss.points(fp).S(1,1);
    Sl = tsl.points(fp).S(1,1);

    S = zeros(2);
    S(1,1) = p1cal(Sm, Sos, Ss, Sl, Gosmodel, -1, 0);
    S(2,1) = 1;
    S(1,2) = 1;
    S(2,2) = 0;

    ts.points(fp).S = S;

end

plot1port(ts, 64);

pause();
