% script matrix1

% port impedance
Z0 = 50



% common functions
addpath("../RFlib")

ts = touchstoneread('nanovna1.s1p')

S11 = []

for a = 1:length(ts.points)
    S11 = [S11; abcd2s(ts.points(a).ABCD, ts.points(a).Z)(1,1)]
end

smithplot(S11, 'S')
ylabel("S1,1");

pause()


