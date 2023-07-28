% script matrix1

% 100MHz - 2000MHz
sweeppoints = 500e+6:10e+6:2000e+6;

% common functions
addpath("../RFlib")

% source 
Z0 = 50
% imaginary Z
Zm = 5
% load 
ZL = 500

% the frequency
Fm = 1e+9

Ql = sqrt((Z0/Zm)-1)
Qr = sqrt((ZL/Zm)-1)

% capacitor
Cl = Admittance(Z0/Ql) / Omega(Fm)

% inductor
Ll = (Zm*Ql) / Omega(Fm)
Lr = (Zm*Qr) / Omega(Fm)

% capacitor
Cr = Admittance(ZL/Qr) / Omega(Fm)

S11complexplot = []
S11dBplot = []


for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % 1/4 wave tline
    
    M = TLineMatrix(Z0, f2rad(f, 1e+9)/4)

    M = M * ShuntImpedanceMatrix(CapacitorImpedance(Cl, f));
    M = M * SeriesImpedanceMatrix(InductorImpedance(Ll + Lr, f));
    M = M * ShuntImpedanceMatrix(CapacitorImpedance(Cr, f));

    % termination
    M = M * ShuntImpedanceMatrix(500.0)
    % isolation from port 2
    M = M * SeriesImpedanceMatrix(9e+9)



    S = abcd2s(M, Z0)


    S11dBplot = [S11dBplot; gamma2db(S(1,1))]
    S11complexplot = [S11complexplot; S(1,1)]

end

subplot(1, 2, 1)
plot(sweeppoints, S11dBplot)
xlabel("f(Hz)");
ylabel("S1,1(dB)");

subplot(1, 2, 2)
smithgplot(S11complexplot)
ylabel("S1,1");

Cl
Ll + Lr
Cr

pause()


