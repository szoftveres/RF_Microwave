
function M = RectangularWaveguideTerminationMatrix(a, b, f)
    M = ShuntImpedanceMatrix(RectangularWaveguideCharacteristicImpedance(a, b, f));
end

