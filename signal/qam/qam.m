% script matrix1

n_symbols = 8192
dim = 8

% common functions
addpath("../octavelib")


% Generating the random symbols

for noisep = 1:10

    ri = randi([0 dim-1], 1, n_symbols);
    rq = randi([0 dim-1], 1, n_symbols);

    iq = zeros(n_symbols,1);

    for fp = 1:n_symbols
        iq(fp) = ((ri(fp) - ((dim - 1) / 2)) / dim + j * ((rq(fp) - ((dim - 1) / 2))) / dim);
    end

    iq_orig = iq;

    %%% channel start %%%

    % Adding white noise

    SNRdB = 18-noisep;

    iq = whitenoise(iq, SNRdB);

    % Adding phase noise

    noiselevel = 0.1;

    iq = phasenoise(iq, noiselevel);

    %%% channel end %%%

    % Plotting

    qamplot(iq, dim)
    title("SNR: 18dB")
    errors = qam_compare(iq, iq_orig, dim)
    pause(0.5)
end

pause()


