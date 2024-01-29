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
    Sm = abcd2s(tsm.points(fp).ABCD, Z0);

    So = abcd2s(tso.points(fp).ABCD, Z0);
    Ss = abcd2s(tss.points(fp).ABCD, Z0);
    Sl = abcd2s(tsl.points(fp).ABCD, Z0);

    S = p1cal(Sm, So, Ss, Sl, 1, -1, 0, Z0);

    ts.points(fp).ABCD = s2abcd(S, Z0);

end

plot1port(ts, 64);

pause();

%%%%%%%%%%%%%%%%%%%%%%%%%
% OFFSET SHORT, SHORT, LOAD

for fp = 1:length(ts.points)
    f = ts.points(fp).f;
    Sm = abcd2s(tsm.points(fp).ABCD, Z0);

    % Building an offset short model
    Mosmodel = TLineMatrix(Z0, f2rad(f, 161.2e+6) / 4);
    Mosmodel = Mosmodel * ShuntImpedanceMatrix(1e-9);
    Mosmodel = Mosmodel * SeriesImpedanceMatrix(9e9);
    Sosmodel = abcd2s(Mosmodel, Z0);
    Gosmodel = Sosmodel(1,1);

    Sos = abcd2s(tsos.points(fp).ABCD, Z0);
    Ss = abcd2s(tss.points(fp).ABCD, Z0);
    Sl = abcd2s(tsl.points(fp).ABCD, Z0);

    S = p1cal(Sm, Sos, Ss, Sl, Gosmodel, -1, 0, Z0);

    ts.points(fp).ABCD = s2abcd(S, Z0);

end

plot1port(ts, 64);

pause();
