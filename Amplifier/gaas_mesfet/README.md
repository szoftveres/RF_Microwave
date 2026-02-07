## GaAs MESFET low-noise antenna amplifier for 440 MHz

![pic](pic.jpg)

![schem](schem.png)

#### Description

The amplifier is designed to be installed right at the antenna, DC power is supplied through the coax cable. Its main purpose is to provide low receiver noise figure when the antenna is installed far away from the receiver (e.g. in the attic).

The input is tuned with a high-Q LC filter, matching is provided by a series trimmer capacitor. The two degrees of freedom at the input enables optimum NF vs. reflection coefficient adjustment.

The amplifying device is a Motorola MRF966 dual-gate MES-FET, capable of NF=0.6 dB at 450 MHz, biased at 15 mA.

The output is implemented with a hand-wound broadband transmission line RF transformer, creating a 200Ω -> 50Ω transition. A 680Ω resistor degenerates any resonance peaks at the output, ensuring stability. 

Gain is +16 dB at 440 MHz, DC current is 15 mA (supply voltage range: 7V - 35V) .

![out_pic](out_pic.jpg)


