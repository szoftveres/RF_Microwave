% script transistor.m

% Port impedance
Z0 = 50 + j * 0

% common functions
addpath("../RFlib")

% 915MHz
f = 915e+6

S = zeros(2)
S(1,1) = -0.41 - j * 0.25
S(2,1) = -0.09 - j * 5.19
S(1,2) = -0.05 - j * 0.05
S(2,2) = 0.38 - j * 0.31

Tin = TLineMatrix(50.0, deg2rad(90))
Tout = TLineMatrix(50.0, deg2rad(90))
Mstab = SeriesImpedanceMatrix(35.0)

% Step 1: de-embedding

M = s2abcd(S, Z0)

S = rot90(S,2)
M = M / Tin
S = rot90(S,2)
M = M / Tout

% Step 2: applying series stability resistor at the output

M = M * Mstab

S = abcd2s(M, Z0)
Y = abcd2y(M)

% Step 2: Stability analysis

delta = (S(1,1) * S(2,2)) - (S(1,2) * S(2,1))
K = (1 - (abs(S(1,1)) ^ 2) - (abs(S(2,2)) ^ 2) + (abs(delta) ^ 2)) / (2 * abs(S(1,2) * S(2,1)))

% Step 3: Simultaneous conjugate match

B1 = (1 + (abs(S(1,1)) ^ 2) - (abs(S(2,2)) ^ 2) - (abs(delta) ^ 2))
B2 = (1 + (abs(S(2,2)) ^ 2) - (abs(S(1,1)) ^ 2) - (abs(delta) ^ 2))
C1 = S(1,1) - (delta * conj(S(2,2)))
C2 = S(2,2) - (delta * conj(S(1,1)))

GS1 = (B1 + sqrt((B1 ^ 2) - (4 * (abs(C1) ^ 2)))) / (2 * C1)
GS2 = (B1 - sqrt((B1 ^ 2) - (4 * (abs(C1) ^ 2)))) / (2 * C1)
GL1 = (B2 + sqrt((B2 ^ 2) - (4 * (abs(C2) ^ 2)))) / (2 * C2)
GL2 = (B2 - sqrt((B2 ^ 2) - (4 * (abs(C2) ^ 2)))) / (2 * C2)

if abs(GS1) < 1 
    GS = GS1
else
    GS = GS2
end
if abs(GL1) < 1 
    GL = GL1
else
    GL = GL2
end


Y(2,2)
