% script matrix1

% 415kHz - 475kHz
sweeppoints = 445e+3:0.125e+3:465e+3;

% port impedance
Z0 = 60000 + 0j


S21dBplot = []
S21Angleplot = []
Z11Magplot = []

% common functions
addpath("../ABCDmatrix")

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

    % S2,1 magnitude in dB
    S21dBplot = [S21dBplot; 20*log10(abs(S(2,1)))]
    
    % S2,1 angle in degrees
    S21Angleplot = [S21Angleplot; arg(S(2,1))/pi*180]
    
    % Z1,1 in ohms
    Z11Magplot = [Z11Magplot; abs(Z11)]

end

plot(sweeppoints, S21dBplot)
xlabel("f(Hz)");
ylabel("S2,1(dB)");
pause()
