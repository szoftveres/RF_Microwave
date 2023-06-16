% script matrix1

% 400kHz - 500kHz
sweeppoints = 400e+3:1e+3:500e+3;

% port impedance
Z0 = 200000 + 0j


S21dBplot = []
S21Angleplot = []
Z11Magplot = []

% common functions
addpath("../RFlib")

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % Parallel 690uH lossy inductor (0.1 ohm)     
    L1 = ShuntImpedanceMatrix(SeriesImpedance(0.1, InductorImpedance(690e-6, f)))

    % Series 180pF capacitor 
    C2 = SeriesImpedanceMatrix(CapacitorImpedance(180e-12, f))
         
    % Parallel 6.8nF capacitor     
    C3 = ShuntImpedanceMatrix(CapacitorImpedance(6.8e-9, f))

    % Series 180pF capacitor 
    C4 = SeriesImpedanceMatrix(CapacitorImpedance(180e-12, f))
         
    % Parallel 690uH lossy inductor (0.1 ohm)     
    L5 = ShuntImpedanceMatrix(SeriesImpedance(0.1, InductorImpedance(690e-6, f)))


    M = L1 * C2 * C3 * C4 * L5


    %Z11 = A/C
    Z11 = M(1,1)/M(2,1) 

    S = abcd2s(M, Z0)


    % S2,1 magnitude in dB
    S21dBplot = [S21dBplot; gamma2db(S(2,1))]
    
    % S2,1 angle in degrees
    S21Angleplot = [S21Angleplot; arg(S(2,1))/pi*180]
    
    % Z1,1 in ohms
    Z11Magplot = [Z11Magplot; abs(Z11)]

end

plot(sweeppoints, S21dBplot)
xlabel("f(Hz)");
ylabel("S2,1(dB)");
pause()
