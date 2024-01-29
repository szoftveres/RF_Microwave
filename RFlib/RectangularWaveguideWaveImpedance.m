
function Z = RectangularWaveguideWaveImpedance(a, f, emode)
    k0 = Omega(f) / LightSpeed();

    Z = (k0 * Zfree()) / RectangularWaveguidePhaseConstant(a, f, emode);
end

