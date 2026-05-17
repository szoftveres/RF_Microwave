function G = keysight_cal_open(Z0, f, offset_delay, offset_loss, offset_z0, C0, C1, C2, C3)

    Cend = C0 + (C1 * f) + (C2 * f * f) + (C3 * f * f * f);

    Rser = offset_loss * sqrt(f / 1e9) * offset_delay; % GΩ/sec
    Erad = 2 * pi * offset_delay * f; % Length of the tline relative to wavelength at f
    M = TLineLossyMatrix(offset_z0, Erad, Rser, 1e-19);
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(Cend, f));
    M = M * SeriesImpedanceMatrix(1e19); % Isolation from P2

    Z = abcd2z(M);
    G = z2gamma(Z(1,1), Z0);

end


% https://www.qsl.net/in3otd/electronics/VNA_calkit/SMA_female.html
% https://scikit-rf.readthedocs.io/en/latest/examples/metrology/SOLT%20Calibration%20Standards%20Creation.html
