% fourier.m


symbols = [(0 + 0j),
           (1 + 0j),
           (0 + 0j),
           (0 + 0j),
           (0 + 0j),
           (0 + 0j),
           (0 + 0j),
           (0 + 0j)
];
si = real(symbols);
sq = imag(symbols);

n = length(symbols);

iii = ifft(symbols);
iii

dft = fft(symbols);



% Complex Discrete Fourier Transform

fi = zeros(n,1);
fq = zeros(n,1);
for i = 1:n
    sum_i = 0;
    sum_q = 0;
    for k = 1:n
        ang = 2 * pi * (k-1) * (i-1) / n;
        sum_i = sum_i + (si(k) * cos(ang) + sq(k) * sin(ang));
        sum_q = sum_q + (-si(k) * sin(ang) + sq(k) * cos(ang));
    end
    fi(i) = sum_i;
    fq(i) = sum_q;
end



% Complex Inverse Discrete Fourier Transform

si = zeros(n,1);
sq = zeros(n,1);
for i = 1:n
    sum_i = 0;
    sum_q = 0;
    for k = 1:n
        ang = 2 * pi * (k-1) * (i-1) / n;
        sum_i = sum_i + (fi(k) * cos(ang) - fq(k) * sin(ang));
        sum_q = sum_q + (fi(k) * sin(ang) + fq(k) * cos(ang));
    end
    si(i) = (sum_i / n);
    sq(i) = (sum_q / n);
end


symbols
complex(si, sq)





