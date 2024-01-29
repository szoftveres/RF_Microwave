
function B = RectangularWaveguidePhaseConstant(a, f, emode)
    k0 = Omega(f) / LightSpeed();
    B = sqrt((k0 ^ 2) - (((emode * pi) / a) ^ 2));
end

