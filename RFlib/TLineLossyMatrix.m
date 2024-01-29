
% R = series resistance
% G = shunt conductance

function M = TLineLossyMatrix(Z, Erad, R, G)
    M = zeros(2);
    M(1,1) = cos(Erad);
    M(1,2) = R + sin(Erad) * Z * j;
    M(2,1) = G + sin(Erad) * Admittance(Z) * j;
    M(2,2) = cos(Erad);
end

