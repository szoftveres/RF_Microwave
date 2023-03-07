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


function M = TLineMatrix(Z, Edeg)
    M = zeros(2)
    M(1,1) = cos(Edeg)
    M(1,2) = sin(Edeg) * Z * j
    M(2,1) = sin(Edeg) * Admittance(Z) * j
    M(2,2) = cos(Edeg)
end


% The frequency: 1.5GHz
f = 1.5e+9


% The impedance, as seen by the VNA / ADS
Z = 24 - j * 12


M = ParallelImpedanceMatrix(Z)

% The TLine to deembed
M = M / TLineMatrix(50.0, 90)


% By definition, Z1,1 = A/C
M(1,1) / M(2,1)




