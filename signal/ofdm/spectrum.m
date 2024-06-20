% script spectrum

n_carriers = 16;
dim = 4;

% common functions
addpath("../octavelib")


% Generating the packets with random symbols


data_snd = []


ri = [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
rq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

for fp = 1:n_carriers
    data_snd = [data_snd; ri(fp) + j * rq(fp) ];
end

% Generating the waveform by inverse Fourier-transforming the symbols


waveform = ifft(data_snd)

waveform = [waveform(n_carriers); waveform(1:end-1)]

waveform = fft(waveform)

subplot(2,2,1)
plot(1:n_carriers, real(waveform))
ylabel("real")

subplot(2,2,3)
plot(1:n_carriers, imag(waveform))
ylabel("imag")

subplot(2,2,2)
plot(1:n_carriers, abs(waveform))
ylabel("magnitude")

subplot(2,2,4)
plot(1:n_carriers, angle(waveform) * 180 / pi)
ylabel("angle")

pause()
exit()



