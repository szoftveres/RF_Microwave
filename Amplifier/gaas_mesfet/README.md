## GaAs MESFET low-noise antenna amplifier for 440 MHz

The amplifier is designed to be installed right at the antenna, its main purpose is to compensate for the loss of a long antenna cable and provide low receiver noise figure. DC power is supplied through the coax cable.

The amplifying device is a Motorola MRF966 dual-gate MES-FET, capable of NF=0.6 dB at 450 MHz.

![pic](pic.jpg)

![schem](schem.png)

#### Description

The input is tuned with a high-Q LC filter, matching is provided by a series trimmer capacitor (C5). The two degrees of freedom (C5 and C4) enables optimum NF vs. reflection coefficient adjustment.

The output is implemented with a hand-wound broadband transmission line RF transformer, creating a 200Ω -> 50Ω transition. A 680Ω resistor (R4) degenerates any resonance peaks at the output, ensuring stability. 

![out_pic](out_pic.jpg)

#### Input matching strategy (best noise figure vs. lowest reflection coefficient)

FETs are voltage controlled devices with infinite input impedance at low fequencies, so naturally they perform the best (highest amplification and lowest noise contribution) when they're driven by a high voltage + low current (= high impedance) source.

![gopt](gopt.png)

The datasheet calls for an optimum source impedance at 450 MHz that corresponds to 115.9 + j207.9 Ω. This source impedance is quite, so an L-match (C5, and an imaginary inductance that's absorbed into the L1 C4 tank) transforms the antenna impedance up to the desired optimum. The combination of C4 and C5 allows a wide range of input impedance to be set, including a perfect match.

Since I don't have a noise meter, nor can deduce any information about the exact impedance at the transistor gate (the exact capacitance of the trimmers are unknonw at any particular setting, hence the impedance transformation ratio is also unknown), I chose an intuitive approach: I trim the variable capacitors for the highest gain and lowest input impedance while maintaining a somewhat acceptable reflection coefficient. This strategy ensures the highest impedance at the gate (for highest voltage -> good noise figure), and also has the benefit of a resulting in a somewhat broader bandwidth, due to the gate impedance of the transistor (and also the Q of the inductor and trimmer cap) now affecting the overall Q of the LC tank.

S-parameters after tuning for 440 MHz, and low, but acceptable input imepdance:

![sparm](sparm.png)

Gain is +18.4 dB at 440 MHz, 3 dB bandwidth is 23 MHz (429-452 MHz), return loss is -13 dB at 440 MHz


Power sweep at 440 MHz:

![pwrsweep](pwrsweep.png)

OP1dB = +3 dBm, OP3dB = +6.45 dBm, DC current is 15 mA (supply voltage range: 7V - 35V).
