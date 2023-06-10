% script display touchstone

% port impedance
Z0 = 50

% common functions
addpath("../RFlib")

ts = touchstoneread('nanovna1.s1p')

plot2ports(ts, 37)

pause()


