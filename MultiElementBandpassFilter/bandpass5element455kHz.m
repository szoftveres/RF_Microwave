% script matrix1

% 415kHz - 475kHz
sweeppoints = 445e+3:0.125e+3:465e+3;

% port impedance
Z0 = 60000 + 0j


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

    % 665uH lossy inductor with series 4ohms 
    M = ParallelImpedanceMatrix(SeriesImpedance(4, InductorImpedance(665e-6, f)))

    % 180pF capacitor
    M = M * ParallelImpedanceMatrix(CapacitorImpedance(180e-12, f))

    % Adding the remaining 4 elements in a loop
    for element = 1:4

        % 2pF coupling capacitor
        M = M * SeriesImpedanceMatrix(CapacitorImpedance(2e-12, f))

        % 665uH lossy inductor with series 4ohms 
        M = M * ParallelImpedanceMatrix(CapacitorImpedance(180e-12, f))
         
        % 180pF capacitor
        M = M * ParallelImpedanceMatrix(SeriesImpedance(4, InductorImpedance(665e-6, f)))

    end


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
