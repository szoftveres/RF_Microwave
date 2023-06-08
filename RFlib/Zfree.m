
function Z = Zfree()
    Mu0 = 4 * pi * 1e-7
    E0 = 1 / (Mu0 * LightSpeed() ^ 2)
    Z = sqrt(Mu0 / E0)
end

