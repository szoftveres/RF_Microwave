% script matrix1

% 400kHz - 500kHz
f = 400e+3:1e+3:500e+3;

% port impedance
Z0 = 200000 + 0j


S21dBplot = []
S21Angleplot = []
Z11Magplot = []


for i = 1:length(f)

    omega = 2 * pi * f(i)

         
    % Parallel 690uH lossy inductor (0.1 ohm)     
    P1 = [1 0;
         1/(0.1 + (omega * 690e-6)*j) 1]

    % Series 180pF capacitor 
    P2 = [1 0 - (1/(omega * 180e-12))*j;
         0 1]
         
    % Parallel 6.8nF capacitor     
    P3 = [1 0;
         1/(0 - (1/(omega * 6.8e-9))*j) 1]

    % Series 180pF capacitor 
    P4 = [1 0 - (1/(omega * 180e-12))*j;
         0 1]
         
    % Parallel 690uH lossy inductor (0.1 ohm)     
    P5 = [1 0;
         1/(0.1 + (omega * 690e-6)*j) 1]


    M = P1 * P2 * P3 * P4 * P5


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

plot(f, S21dBplot)
