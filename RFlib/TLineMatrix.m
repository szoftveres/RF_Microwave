
function M = TLineMatrix(Z, Erad)
    M = zeros(2);
    M(1,1) = cos(Erad);
    M(1,2) = sin(Erad) * Z * j;
    M(2,1) = sin(Erad) * Admittance(Z) * j;
    M(2,2) = cos(Erad);
end

