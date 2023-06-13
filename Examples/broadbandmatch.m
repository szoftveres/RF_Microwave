% script matrix1

% 100MHz - 2000MHz
sweeppoints = 100e+6:10e+6:2000e+6;

% port impedance
Z0 = 50 + 0j

% common functions
addpath("../RFlib")

function M = SteppedLines(M, level, Zl, Zr, f)
    if level > 3
        return
    end
    Zmid = sqrt(Zl * Zr)
    M = SteppedLines(M, level+1, Zl, Zmid, f)
    M = M * TLineMatrix(Zmid, f2rad(f, 1e9)/4)
    M = SteppedLines(M, level+1, Zmid, Zr, f)
    return
end


S11complexplot = []
S11dBplot = []


for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % 1/4 wave tline
    
    M = TLineMatrix(Z0, f2rad(f, 1e+9)/4)
    M = SteppedLines(M, 0, Z0, 10.0, f)

    % 10 ohms
    M = M * ShuntImpedanceMatrix(10.0)



    S = abcd2s(M, Z0)


    S11dBplot = [S11dBplot; 20*log10(abs(S(1,1)))]
    S11complexplot = [S11complexplot; S(1,1)]

end

subplot(1, 2, 1)
plot(sweeppoints, S11dBplot)
xlabel("f(Hz)");
ylabel("S1,1(dB)");

subplot(1, 2, 2)
smithgplot(S11complexplot)
ylabel("S1,1");

pause()


