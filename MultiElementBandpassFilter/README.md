# Transfer matrix simulation of two loosely coupled resonant tank circuits

This is the GNU Octave (MATLAB-alike) simulation of two, loosely coupled LC tank circuits (fc around 455kHz), using the cascaded transfer matrix technique.

```
        L1              C2              C3              C4              L5
      parallel        series         parallel         series         parallel
      inductor       capacitor       capacitor       capacitor       inductor

M = | 1     0 |  x  | 1 Z(c2) |  x  | 1     0 |  x  | 1 Z(c4) |  x  | 1     0 |
    | Y(l1) 1 |     | 0     1 |     | Y(c3) 1 |     | 0     1 |     | Y(l5) 1 |
```

![image circuit2](circuit2.png)

## CLI command under linux with GNU Octave:
`octave ./bandpass2element455kHz.m`

## S2,1 results

![image s212](s212.png)




# 5 element bandpass filter centered at 455kHz

Transfer matrix modeling and simulation with realistic inductor losses and port impedances

![image circuit](circuit.png)

## CLI command under linux with GNU Octave:
`octave ./bandpass5element455kHz.m`

## S2,1 results

![image s21](s21.png)



