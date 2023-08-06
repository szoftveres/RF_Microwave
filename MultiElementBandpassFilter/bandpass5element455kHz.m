% script matrix1

% 415kHz - 475kHz
sweeppoints = 445e+3:0.125e+3:465e+3;

% port impedance
Z0 = 60000 + 0j


S21plot = []

% common functions
addpath("../RFlib")

for fp = 1:length(sweeppoints)

    f = sweeppoints(fp)

    % 665uH lossy inductor with series 4ohms 
    M = ShuntImpedanceMatrix(SeriesImpedance(4, InductorImpedance(665e-6, f)))

    % 180pF capacitor
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(180e-12, f))

    % Adding the remaining 4 elements in a loop
    for element = 1:4

        % 2pF coupling capacitor
        M = M * SeriesImpedanceMatrix(CapacitorImpedance(2e-12, f))

        % 665uH lossy inductor with series 4ohms 
        M = M * ShuntImpedanceMatrix(CapacitorImpedance(180e-12, f))
         
        % 180pF capacitor
        M = M * ShuntImpedanceMatrix(SeriesImpedance(4, InductorImpedance(665e-6, f)))

    end


    %Z11 = A/C
    Z11 = M(1,1)/M(2,1) 

    S = abcd2s(M, Z0)

    S21plot = [S21plot; S(2,1)]
end

dbplot(S21plot, sweeppoints)
xlabel("f(Hz)");
ylabel("S2,1(dB)");
pause()
