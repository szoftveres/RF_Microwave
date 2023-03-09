% script deembed.m


% 1.5GHz
f = 1.5e+9


function Y = Admittance(Z)
    Y = 1 / Z
end

function O = Omega(F)
    O = 2 * pi * F
end

function M = SeriesImpedanceMatrix(Z)
    M = zeros(2)
    M(1,1) = 1 + 0j
    M(1,2) = Z
    M(2,1) = 0 + 0j
    M(2,2) = 1 + 0j
end

function M = ParallelImpedanceMatrix(Z)
    M = zeros(2)
    M(1,1) = 1 + 0j
    M(1,2) = 0 + 0j
    M(2,1) = Admittance(Z)
    M(2,2) = 1 + 0j
end

function Z = CapacitorImpedance(C, F)
    Z = 0 - (1/(Omega(F) * C))*j
end

function Z = InductorImpedance(L, F)
    Z = 0 + (Omega(F) * L)*j
end

function Z = ParallelImpedance(Z1, Z2)
    Z = 1 / ((1 / Z1) + (1 / Z2))
end

function Z = SeriesImpedance(Z1, Z2)
    Z = Z1 + Z2
end


function M = TLineMatrix(Z, Erad)
    M = zeros(2)
    M(1,1) = cos(Erad)
    M(1,2) = sin(Erad) * Z * j
    M(2,1) = sin(Erad) * Admittance(Z) * j
    M(2,2) = cos(Erad)
end

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


