% script display touchstone

% port impedance
Z0 = 50

% common functions
addpath("../RFlib")

ts = touchstoneread('nanovna2.s2p')

plot2ports(ts, 69)

touchstonewrite('out.s2p', ts)

pause()


