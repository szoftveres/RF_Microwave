function M = RectangularWaveguideMatrix(a, b, l, f)
    Zcharacteristic = RectangularWaveguideCharacteristicImpedance(a, b, f);

    BetaZ = RectangularWaveguidePhaseConstant(a, f, 1);

    M = TLineMatrix(Zcharacteristic, BetaZ * l);
end

