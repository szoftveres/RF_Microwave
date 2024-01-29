% script deembed.m


% 377MHz
f = 377e+6;

% common functions
addpath("../RFlib")

% Port impedance
Z0 = 50 + j * 0;

% The impedance, as seen by the VNA
Z11 = 48.4 + j * 39.5;

% Building the S-parameter matrix
S = zeros(2);
S(1,1) = z2gamma(Z11, Z0);
S(1,2) = 1e-9;           % almost zero 
S(2,1) = 1e-9;           % almost zero
S(2,2) = 1 - 1e-9;       % almost one

% Flipping (pretending that we're interested in port 2)
S = rot90(rot90(S));

% Converting to ABCD matrix
M = s2abcd(S, Z0);

% The TLine to deembed: 50 ohms, 90 degrees
MT = TLineMatrix(50.0, deg2rad(80));

% If the 2x-thru parameters are available, we can just apply
% sqrt operation on them to get one of the fixtures
% M = sqrtm(M);

% De-embedding
M = M / MT;

% By definition, Z22 = D/C
M(2,2) / M(2,1)


