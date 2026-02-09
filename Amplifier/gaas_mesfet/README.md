## GaAs MESFET low-noise antenna amplifier for 440 MHz

The amplifier is designed to be installed right at the antenna, its main purpose is to compensate for the loss of a long antenna cable and provide low receiver noise figure. DC power is supplied through the coax cable.

The amplifying device is a Motorola MRF966 dual-gate MES-FET, capable of NF=0.6 dB at 450 MHz.

Gain is +16 dB at 440 MHz, DC current is 15 mA (supply voltage range: 7V - 35V) .

![pic](pic.jpg)

![schem](schem.png)

#### Description

The input is tuned with a high-Q LC filter, matching is provided by a series trimmer capacitor (C5). The two degrees of freedom (C5 and C4) enables optimum NF vs. reflection coefficient adjustment.

The output is implemented with a hand-wound broadband transmission line RF transformer, creating a 200Ω -> 50Ω transition. A 680Ω resistor (R4) degenerates any resonance peaks at the output, ensuring stability. 

![out_pic](out_pic.jpg)
