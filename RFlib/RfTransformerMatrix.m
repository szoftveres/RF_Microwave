function M = RfTransformerMatrix(Lpri, Lsec, Kfactor, f)
    N = sqrt(Lpri / Lsec)

    Lmpri = Lpri * Kfactor
    Llpri = Lpri * (1.0 - Kfactor)
    Llsec = Lsec * (1.0 - Kfactor)

    M = SeriesImpedanceMatrix(InductorImpedance(Llpri, f))
    M = M * ShuntImpedanceMatrix(InductorImpedance(Lmpri, f))

    Mtrans = zeros(2)
    Mtrans(1,1) = N
    Mtrans(1,2) = 0
    Mtrans(2,1) = 0
    Mtrans(2,2) = 1 / N

    M = M * Mtrans
    M = M * SeriesImpedanceMatrix(InductorImpedance(Llsec, f))
end

