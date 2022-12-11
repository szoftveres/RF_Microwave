% script matrix1

% 400kHz - 500kHz
sweeppoints = 400e+3:1e+3:500e+3;

% port impedance
Z0 = 200000 + 0j


S21dBplot = []
S21Angleplot = []
Z11Magplot = []

function Y = Admittance(Z)
    Y = 1 / Z
end

function O = Omega(F)
    O = 2 * pi * F
end

function M = SeriesImpedanceMatrix(Z)
    M = zeros(2)
    M(1,1) = 1 + 0j
    M(1,2) = Z
    M(2,1) = 0 + 0j
    M(2,2) = 1 + 0j
end

function M = ParallelImpedanceMatrix(Z)
    M = zeros(2)
    M(1,1) = 1 + 0j
    M(1,2) = 0 + 0j
    M(2,1) = Admittance(Z)
    M(2,2) = 1 + 0j
end

function Z = CapacitorImpedance(C, F)
    Z = 0 - (1/(Omega(F) * C))*j
end

function Z = InductorImpedance(L, F)
    Z = 0 + (Omega(F) * L)*j
end

function Z = ParallelImpedance(Z1, Z2)
    Z = 1 / ((1 / Z1) + (1 / Z2))
end

function Z = SeriesImpedance(Z1, Z2)
    Z = Z1 + Z2
end

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % Parallel 690uH lossy inductor (0.1 ohm)     
    L1 = ParallelImpedanceMatrix(SeriesImpedance(0.1, InductorImpedance(690e-6, f)))

    % Series 180pF capacitor 
    C2 = SeriesImpedanceMatrix(CapacitorImpedance(180e-12, f))
         
    % Parallel 6.8nF capacitor     
    C3 = ParallelImpedanceMatrix(CapacitorImpedance(6.8e-9, f))

    % Series 180pF capacitor 
    C4 = SeriesImpedanceMatrix(CapacitorImpedance(180e-12, f))
         
    % Parallel 690uH lossy inductor (0.1 ohm)     
    L5 = ParallelImpedanceMatrix(SeriesImpedance(0.1, InductorImpedance(690e-6, f)))


    M = L1 * C2 * C3 * C4 * L5


    %Z11 = A/C
    Z11 = M(1,1)/M(2,1) 

    %S21 = 2 / (A + B/Z0 + C*Z0 + D)
    S21 = 2 / (M(1,1) + (M(1,2)/Z0) + (M(2,1)*Z0) + M(2,2))


    % S2,1 magnitude in dB
    S21dBplot = [S21dBplot; 10*log10(abs(S21))]
    
    % S2,1 angle in degrees
    S21Angleplot = [S21Angleplot; arg(S21)/pi*180]
    
    % Z1,1 in ohms
    Z11Magplot = [Z11Magplot; abs(Z11)]

end

plot(sweeppoints, S21dBplot)
xlabel("f(Hz)");
ylabel("S2,1(dB)");
pause()
