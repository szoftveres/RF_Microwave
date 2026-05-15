function G = keysight_cal_short(Z0, f, offset_delay, offset_loss, offset_z0, L0, L1, L2, L3)

    Lend = L0 + (L1 * f) + (L2 * f * f) + (L3 * f * f * f);

    Rser = offset_loss * sqrt(f / 1e9) * offset_delay; % GΩ/sec
    Erad = 2 * pi * offset_delay * f; % Length of the tline relative to wavelength at f
    M = TLineLossyMatrix(offset_z0, Erad, Rser, 1e-19);
    M = M * ShuntImpedanceMatrix(InductorImpedance(Lend, f));
    M = M * SeriesImpedanceMatrix(1e19); % Isolation from P2

    Z = abcd2z(M);
    G = z2gamma(Z(1,1), Z0);

end


% Offset Loss
% The nominal attenuation at 1 GHz per unit time, given in GΩ/s (gigaohms per second). Scale this value by sqrt(f / (1 GHz)) for other frequencies. The unit GΩ/s is unconventional, but for a reason. To express a transmission line segment’s length, both a distance (in meters) or a time delay (in seconds) can be used. Defining the line with respect to time allows calculating R = Aloss * Tdelay in ohms, without needing to explicitly define the medium permittivity.

