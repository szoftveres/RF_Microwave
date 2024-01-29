% fourier.m


symbols = [(0 + 5j),  (-2 + 2j),  (3 - 1j),  (-1 -1j)]
si = real(symbols)
sq = imag(symbols)

n = length(symbols)

dft = fft(symbols)



% Complex Discrete Fourier Transform

fi = []
fq = []
for i = 1:n
    sum_i = 0
    sum_q = 0
    for k = 1:n
        ang = 2 * pi * (k-1) * (i-1) / n
        sum_i = sum_i + (si(k) * cos(ang) + sq(k) * sin(ang));
        sum_q = sum_q + (-si(k) * sin(ang) + sq(k) * cos(ang));
    end
    fi = [fi; sum_i]
    fq = [fq; sum_q]
end



% Complex Inverse Discrete Fourier Transform

si = []
sq = []
for i = 1:n
    sum_i = 0
    sum_q = 0
    for k = 1:n
        ang = 2 * pi * (k-1) * (i-1) / n
        sum_i = sum_i + (fi(k) * cos(ang) - fq(k) * sin(ang));
        sum_q = sum_q + (fi(k) * sin(ang) + fq(k) * cos(ang));
    end
    si = [si; (sum_i / n)]
    sq = [sq; (sum_q / n)]
end


symbols
complex(si, sq)





