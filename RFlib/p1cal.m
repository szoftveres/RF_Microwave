% This funciton takes a raw measured S-parameter matrix
% and deembeds an error correction matrix from it
% which is obtained from raw measured So (open), Ss (short)
% and Sl (load). Z0 is the system port impedance

function S = p1cal(S, So, Ss, Sl, Z0)
    Go = So(1,1)
    Gs = Ss(1,1)
    Gl = Sl(1,1)

    gopen = 1 - 1e-9
    gshort = -1 * gopen
    gload = 1e-9

    % Error coefficients
    C = [gopen 1 (gopen*Go); gshort 1 (gshort*Gs); gload 1 (gload*Gl)]
    V = [Go; Gs; Gl]

    E = inv(C' * C) * C' * V
    e00 = E(2)
    e11 = E(3)
    e10e01 = E(1) + (E(2) * E(3))

    % Error network S-parameters
    Se = zeros(2)
    Se(1,1) = e00
    Se(1,2) = sqrt(e10e01)
    Se(2,1) = sqrt(e10e01)
    Se(2,2) = e11

    % Error network ABCD matrix (rotated, for de-embedding)
    Me = s2abcd(rot90(rot90(Se)), Z0)

    % rotated measured network matrix
    M = s2abcd(rot90(rot90(S)), Z0)

    % De-embedding the error matrix
    M =  M / Me

    % rotating back and converting to S matrix
    S = rot90(rot90(abcd2s(M, Z0)))
end


