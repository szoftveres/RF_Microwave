% script matrix1

% 800MHz - 1.2GHz
sweeppoints = 800e+6:5e+6:1200e+6;

% port impedance
Z0 = 50 + 0j


Z11realplot = []
Z11imagplot = []

% common functions
addpath("../RFlib")

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % Parallel cap     
    C1 = ShuntImpedanceMatrix(CapacitorImpedance(1.5e-12, f))

    % TLine
    T2 = TLineMatrix(100.0, f2rad(f, 1500e+6)/4)
         
    % Parallel cap
    C3 = ShuntImpedanceMatrix(CapacitorImpedance(5e-12, f))

    % Termination
    R4 = ShuntImpedanceMatrix(Z0)

    M = C1 * T2 * C3 * R4

    %Z11 = A/C
    Z = abcd2z(M)

    % Z1,1 in ohms
    Z11realplot = [Z11realplot; real(Z(1,1))]
    Z11imagplot = [Z11imagplot; imag(Z(1,1))]

end

subplot(2, 2, 1)
plot(sweeppoints, Z11realplot)
xlabel("f(Hz)");
ylabel("Z real (ohm)");

subplot(2, 2, 2)
plot(sweeppoints, Z11imagplot)
xlabel("f(Hz)");
ylabel("Z imag (ohm)");


pause()
