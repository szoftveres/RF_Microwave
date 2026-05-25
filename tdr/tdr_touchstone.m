Z0 = 50.0;

% common functions
addpath("../RFlib")

plot_factor = 4;

filename = input ("filename: " );
ts = touchstoneread(filename);

sweeppoints = ts2sweep(ts);
points = length(sweeppoints);

S11complexplot = [0];

for fp = 1:points
    S11 = ts.points(fp).S(1,1);
    S11complexplot = [S11complexplot; S11];
end
for fp = 1:points
    S11complexplot = [S11complexplot; 0];
end

ifftplot = ifft(S11complexplot);

figure;
subplot (2,1,1);
plot(sweeppoints(1:(points/plot_factor)), ifftplot(1:(points/plot_factor)), "LineWidth", 2);
xlabel("time");
ylabel("reflection");

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
plot(sweeppoints(1:(points/plot_factor)), stepplot2(1:(points/plot_factor)), "LineWidth", 2);
xlabel("Time");
ylabel("Impedance (Ω)");

axis([1 sweeppoints(floor(points/plot_factor)) 30 55]);
pause();


