% script matrix1

% 100MHz - 2000MHz
sweeppoints = 100e+6:10e+6:2000e+6;

% port impedance
Z0 = 50 + 0j
ZL = 10


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

ts = sweep2ts(sweeppoints)

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp)

    % 1/4 wave tline
    
    M = TLineMatrix(Z0, f2rad(f, 1e+9)/4)
    M = SteppedLines(M, 0, Z0, ZL, f)

    % 10 ohms
    M = M * ImpedanceTransformerMatrix(ZL, Z0)

    ts.points(fp).ABCD = M
end

plot2ports(ts)

pause()

touchstonewrite([mfilename() '.s2p'], ts)



