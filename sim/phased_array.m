N = 5; % Elements
d = 0.5; % Spacing (in wavelengths)
ph = pi/7; % Phasing
amplitude_window = linspace(1, 1, N);
% amplitude_window = hamming(N);
theta = linspace(-pi/2, pi/2, 720);

% Array factor
AF = zeros(size(theta));
for n = 1:N
    AF = AF + amplitude_window(n) * exp(1i * 2 * pi * (n-1) * d * sin(theta + ph));
end
AF = AF / N;

AF = abs(AF).^2; % Magnitude
AF = max(10 * log10(AF * 100), 0); % Referencing up to 20dB, cutting negative values

figure;
h = polar(theta, AF);
set(h, "linewidth", 3);
set (gca, "rtick", 2:3:20);
title('Array Factor (ref: 20dB)');

pause();

