% script matrix1

% port impedance
Z0 = 50 + 0j

% common functions
addpath("../RFlib")


tsm = touchstoneread('load.s2p')

tso = touchstoneread('opencal.s2p')
tss = touchstoneread('shortcal.s2p')
tsl = touchstoneread('loadcal.s2p')

ts = tsm

for fp = 1:length(ts.points)

    Sm = abcd2s(tsm.points(fp).ABCD, tsm.points(fp).Z)

    So = abcd2s(tso.points(fp).ABCD, tso.points(fp).Z)
    Ss = abcd2s(tss.points(fp).ABCD, tss.points(fp).Z)
    Sl = abcd2s(tsl.points(fp).ABCD, tsl.points(fp).Z)

    S = p1cal(Sm, So, Ss, Sl, ts.points(fp).Z)

    ts.points(fp).ABCD = s2abcd(S, Z0)

end

plot1port(tsm, 20)

pause()

