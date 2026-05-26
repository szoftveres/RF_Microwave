% script matrix1

% 25kHz - 80MHz
sweeppoints = 25e+3:25e+3:80e+6;
points = length(sweeppoints);

Z0 = 50.0;

% common functions
addpath("../RFlib")

plot_factor = 6;

S11complexplot = [0];
for fp = 1:points
    f = sweeppoints(fp);

    M = TLineMatrix(50.0, f2rad(f, 1e+6)/4);
    M = M * TLineMatrix(35.0, f2rad(f, 500e+3)/4);
    M = M * TLineMatrix(50.0, f2rad(f, 1e+6)/4);
    M = M * TLineMatrix(71.0, f2rad(f, 500e+3)/4);
    M = M * TLineMatrix(50.0, f2rad(f, 1e+6)/4);
    M = M * ShuntImpedanceMatrix(Z0);
    M = M * SeriesImpedanceMatrix(9e9);

    S = abcd2s(M, Z0);

    S11complexplot = [S11complexplot; S(1,1)];

end
for fp = 1:points
    negf = S11complexplot(points+1-fp+1);
    S11complexplot = [S11complexplot; conj(negf)];
end

timestep = 1 / (sweeppoints(points) * 2);
maxtime = points * timestep;
timepoints = 0:timestep:maxtime;
timepoints = timepoints(1:points/plot_factor);

ifftplot = ifft(S11complexplot);

figure;
subplot (2,1,1);
plot(timepoints, ifftplot(1:(points/plot_factor)), "LineWidth", 2);
xlabel("time (s)");
ylabel("Reflection");

ifftplot2 = [];
for fp = 1:(points/plot_factor)
    ifftplot2 = [ifftplot2; gamma2z(ifftplot(fp), Z0)];
end
stepplot = [0];
stepplot2 = [Z0];
for fp = 2:(points/plot_factor)
    stepplot = [stepplot; stepplot(fp-1) + ifftplot(fp)];
    stepplot2 = [stepplot2; gamma2z(stepplot(fp), Z0)];
end

subplot (2,1,2);
plot(timepoints, stepplot2(1:(points/plot_factor)), "LineWidth", 2);
xlabel("time (s)");
ylabel("Impedance (Ω)");

%axis([0 timepoints(length(timepoints)) 25 70]);
pause();


