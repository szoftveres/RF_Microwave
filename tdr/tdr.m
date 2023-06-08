% script matrix1

% 50kHz - 10MHz
sweeppoints = 50e+3:25e+3:20e+6;
points = length(sweeppoints)

Z0 = 50.0 + 0j


S11complexplot = []
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

    S = abcd2s(M, Z0)

    % Applying (artificial Kaiser) windowing
    S11 = (S(1,1) * ((h(fp)/3) + 0.66))
    %S11 = S(1,1)

    S11complexplot = [S11complexplot; S11]
end


ifftplot = ifft(S11complexplot)


plot(sweeppoints(1:(length(sweeppoints)/8)), ifftplot(1:(length(sweeppoints)/8)))
xlabel("time");
ylabel("reflection");
pause()


stepplot = [0]
for fp = 2:points
    stepplot = [stepplot; stepplot(fp-1) + ifftplot(fp)]
end

plot(sweeppoints(1:(length(sweeppoints)/8)), stepplot(1:(length(sweeppoints)/8)))
xlabel("time");
ylabel("impedance");
pause()
