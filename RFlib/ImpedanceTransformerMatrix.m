function M = ImpedanceTransformerMatrix(Zin, Zout)
    N = sqrt(Zin / Zout)
    M = zeros(2)
    M(1,1) = N
    M(1,2) = 0
    M(2,1) = 0
    M(2,2) = 1 / N
end
