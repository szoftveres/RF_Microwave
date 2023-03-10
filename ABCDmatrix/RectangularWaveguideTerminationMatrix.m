
function M = RectangularWaveguideTerminationMatrix(a, b, f)
    M = ParallelImpedanceMatrix(RectangularWaveguideCharacteristicImpedance(a, b, f))
end

