## 915 MHz Bandpass Filter

Microstrip "hairpin" filter optimized for the ISM band (902MHz - 928MHz).

Due to the stub nature of the filter, resonances appear at every odd harminics, however the appropriate placement of the input- and output ports along the length of the shorted stubs ensure that the ports are only matched at the fundamental frequency and therefore odd harmonics are adequately suppressed by the virtue of mismatch.

The bandwidth of the filter is primarily controlled by the coupling (i.e. spacing) between the stubs - e.g. the closer the coupling, the wider the passband becomes. With closer coupling however, the impedance of the open ends of the shorted stubs decrease (and vice versa for lighter coupling), this needs to be compensated by moving the input- and output port taps higher towards the open end of the stubs, for optimum port match.

Lossy PCB material and therefore high NFmin makes this architecture suitable only for post-LNA or high-level signal filtering applications.

![design](hairpin_design.png)
![build](hairpin_build.jpg)

Narrow-band performance

![sim_nb](hairpin_sim_nb.png)
![meas_nb](hairpin_meas_nb.jpg)

Wide-band performance (simulated and measured)

![sim_wb](hairpin_sim_wb.png)
![meas_wb](hairpin_meas_wb.jpg)

