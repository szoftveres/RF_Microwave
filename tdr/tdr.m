% script matrix1

% 25kHz - 80MHz
sweeppoints = 25e+3:25e+3:80e+6;
points = length(sweeppoints)

Z0 = 50.0 + 0j


S11complexplot = []
Z11complexplot = []
ifftplot = []


% Creating the window
h = hanning(points)

% common functions
addpath("../RFlib")



for fp = 1:points
    f = sweeppoints(fp)

    M = TLineMatrix(50.0, f2rad(f, 1e+6)/4)
    M = M * TLineMatrix(35.0, f2rad(f, 500e+3)/4)
    M = M * TLineMatrix(50.0, f2rad(f, 1e+6)/4)
    M = M * TLineMatrix(71.0, f2rad(f, 500e+3)/4)
    M = M * TLineMatrix(50.0, f2rad(f, 1e+6)/4)
    M = M * ShuntImpedanceMatrix(Z0)

    S = abcd2s(M, Z0)

    S11 = S(1,1)
    % Applying (artificial Kaiser) windowing
    %S11 = (S(1,1) *  ((h(fp)/3) + 0.66))

    S11complexplot = [S11complexplot; S11]
    Z11complexplot = [Z11complexplot; gamma2z(S11, Z0)]

end


ifftplot = ifft(S11complexplot)

plot(sweeppoints(1:(points/12)), ifftplot(1:(points/12)))
xlabel("time");
ylabel("reflection");
pause()


ifftplot2 = []
for fp = 1:(points/12)
    ifftplot2 = [ifftplot2; gamma2z(ifftplot(fp), Z0)]
end
stepplot = [0]
stepplot2 = [Z0]
for fp = 2:(points/12)
    stepplot = [stepplot; stepplot(fp-1) + ifftplot(fp)]
    stepplot2 = [stepplot2; gamma2z(stepplot(fp), Z0)]
end

plot(sweeppoints(1:(points/12)), stepplot2(1:(points/12)))
xlabel("time");
ylabel("impedance");
pause()


