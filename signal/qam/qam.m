% script matrix1

n_symbols = 2048
dim = 8

% common functions
addpath("../RFlib")


% Generating the random symbols

iq = []

ri = randi([0 dim-1], 1, n_symbols);
rq = randi([0 dim-1], 1, n_symbols);


for fp = 1:n_symbols
    iq = [iq; ((ri(fp) - ((dim - 1) / 2)) / dim + j * ((rq(fp) - ((dim - 1) / 2))) / dim)]
end


% Adding white noise

iq_o = iq
iq = []
SNRdB = -18

noiselevel = 10^(SNRdB/10)
for fp = 1:n_symbols
    noisem = rand(1) * noiselevel
    noisea = rand(1) * 2 * pi
    noisesignal = noisem * (cos(noisea) + j*sin(noisea))
    iq = [iq; iq_o(fp) + noisesignal]
end


% Adding phase noise

iq_o = iq
iq = []

noiselevel = 0.2

for fp = 1:n_symbols

    cm = abs(iq_o(fp))
    ca = arg(iq_o(fp))
    noisei = (-0.5 + rand(1)) * noiselevel
    d = cm * (cos(ca + noisei) + j*sin(ca + noisei))
    iq = [iq; d]
end


% Plotting

ri = []
rq = []
for fp = 1:n_symbols
    ri = [ri; real(iq(fp))]
    rq = [rq; imag(iq(fp))]
end

plot(ri, rq, "b.", "LineWidth", 3)
axis([(-0.5) (0.5) (-0.5) (0.5)])
title("SNR: -18dB")

pause()

