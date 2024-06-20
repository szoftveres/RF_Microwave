% script 12thwavetransformer
% https://www.cv.nrao.edu/~demerson/cs/twelfth.htm

% 300MHz - 5GHz

sweeppoints = 300e+6:10e+6:1.5e+9;

l = 11.5e-3;

% common functions

addpath("../RFlib")

ts = sweep2ts(sweeppoints);

Z0 = 50.0;
Z2 = 25.0;

for fp = 1:length(sweeppoints)
    f = sweeppoints(fp);

    % 1/12 wavelength at 1GHz
    B = Z0 / Z2;
    L1 = atan(sqrt(B /(B^2 + B +1)))/(2 * pi);
    L2 = 1/12;

    len = f2rad(f, 1.0e+9) * L1;

    % Shorter section
    M = TLineMatrix(Z2, len);
    M = M * TLineMatrix(Z0, len);

    M = M * ImpedanceTransformerMatrix(Z2, Z0);

    ts.points(fp).ABCD = M;
end

plot2ports(ts, 51);

pause();

