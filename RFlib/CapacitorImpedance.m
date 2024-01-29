function Z = CapacitorImpedance(C, F)
    Z = 0 - (1/(Omega(F) * C))*j;
end

