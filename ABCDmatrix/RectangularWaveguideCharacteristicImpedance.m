
function Z = RectangularWaveguideCharacteristicImpedance(a, b, f)
    Z = RectangularWaveguideWaveImpedance(a, f, 1) * (b / a) * 4
end

