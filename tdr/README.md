# Time Domain Reflection (TDR) simulation from S-parameters

It's known that time-domain signals can be transformed into frequency-domain spectrum, by applying Fourier-transform. Similarly, frequency-domain spectrum can be transformed back into a time-domain signal, by inverse Fourier-transform.

Using the same analogy, time-domain *reflection* can easily be obtained by applying inverse Fourier-transform on the frequency-domain *reflection coefficients* (S1,1), which are the direct result of a VNA S1,1 sweep.

[This script](tdr.m) simulates the S-parameters of a series of transmission lines (each having slightly different characteristic impedance and length), then applies inverse Fourier-transform (plus windowing) on S1,1 to get the time-domain reflection. Finally, it calculates the time-domain impedance plot from the time-domain reflection plot, by integrating the former, as a function of time. 

Simulated network:

![tdrschem](tdrschem.jpg)

Time-domain reflection plot:

![tdrplot1](tdrplot1.png)

Time-domain impedance plot:

![tdrplot3](tdrplot3.png)

