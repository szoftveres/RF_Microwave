% script deembed.m


% 1.5GHz
f = 1.5e+9


addpath("../ABCDmatrix")

% Port impedance
Z0 = 50 + j * 0

% The impedance, as seen by the VNA
% Pretending that we've measured this on port 2
Z22 = 24 - j * 12

% S-parameters for port 2 (S11, S21 and S12 are zero)
S22 = (Z22 - Z0) / (Z22 + Z0)

% ABCD matrix (totally ignoring port 1)
M = zeros(2)
M(2,1) = (1 - S22) * Admittance(Z0)
M(2,2) = (1 + S22)


% The TLine to deembed: 50 ohms, 90 degrees
MT = TLineMatrix(50.0, deg2rad(90))

% De-embedding
M = M / MT

% By definition, Z22 = D/C
M(2,2) / M(2,1)


