% script ofdm

n_packets = 1024;
n_carriers = 4;
dim = 4;

% common functions
addpath("../octavelib")


% Generating the packets with random symbols


data_snd = zeros(n_packets, n_carriers);

datastream_tx = [];

for pck = 1:n_packets

    ri = randi([0 dim-1], 1, n_carriers);
    rq = randi([0 dim-1], 1, n_carriers);

    for fp = 1:n_carriers
        data_snd(pck,fp) = ((ri(fp) - ((dim - 1) / 2)) / dim + j * ((rq(fp) - ((dim - 1) / 2))) / dim);
    end
    datastream_tx = [datastream_tx; data_snd(pck,:)];
end

% Generating the waveform by inverse Fourier-transforming the symbols

waveform = zeros(n_packets, n_carriers);

for pck = 1:n_packets
    waveform(pck,:) = ifft(data_snd(pck,:));
end

%%% channel start %%%


% Adding white noise

for pck = 1:n_packets
    for s = 1:n_carriers
        waveform(pck,s) = whitenoise(waveform(pck,s), 18);
    end
end

%%% channel end %%%

% Demodulating the waveform to symbols by Fourier-transform

data_rec = zeros(n_packets, n_carriers);
for pck = 1:n_packets
    data_rec(pck,:) = fft(waveform(pck,:));
end

% plotting

datastream_rx = [];

for pck = 1:n_packets
    datastream_rx = [datastream_rx; data_rec(pck,:)];
end

qamplot(datastream_rx, dim)
% title("SNR: 18dB")

% calculating the errors caused by noise

qam_compare(datastream_rx, datastream_tx, dim)

pause()


