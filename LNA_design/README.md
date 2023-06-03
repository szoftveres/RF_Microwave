# LNA design

### Goal

Narrow-band LNA for 915MHz, using BJT transistor (BFR91A), with good input- and output match, achieved by two-port bilateral single stub matching.

### The design:

This is a bilateral case, meaning that any change in the matching conditions on one port of the transistor affects the other one, due to the transistor internal (Miller) capacitance. Therefore matching has to be carried out simultaneously on both ports. (Cascode circuits largely overcome this problem by superior isolation between the ports)

The transistor is biased to ~4.5mA (minimum noise figure, according to the datasheet) and the ports are matched with single parallel open stubs. Gain is on the order of ~10dB with good (but narrow-band) input match at 915MHz (ISM mid-band).

Biasing of the collector is implemented by using a 1/4 wave (RF) shorted transmission line, which (as opposed to using an inductor) has the extra benefit of suppressing 2nd order harmonics, due to presenting an RF short at 2f at the collector of the transistor.

![schem](schem.png)

### Stability analysis

This amplifier becomes unconditionally stable with some degeneration of gain, and/or isolation of reactive load from its terminals. This can be achieved by i.e. a series or parallel resistor on its input or output. Attaching the resistor to the output is preferred however, due to the resistor having a contribution to the noise figure.

![stabeq2](stabeq2.jpg)

![stabeq1](stabeq1.png)

One approach is a parallel resistor (R3, 500 ohms, Q degeneration) attached to the collector, at the expense of ~1dB gain loss. Since the resistive component is added after amplification, its contribution to the overall noise figure is negligible.

![stabdegen1](stabdegen1.png)

Stability plots after adding the resistor:

![stabplot1](stabplot1.png)

### The build:

The LNA was built on [FR4 with copper tapes](https://github.com/szoftveres/RF_Microwave/tree/main/Microstrip) - the stability ensuring resistor was not used since the LNA seemed oscillation free, even after tuning.

![pcb1](pcb1.jpg)
![pcb2](pcb2.jpg)

### Results after tuning:

Measured:

![vna](vna.jpg)

Simulated:

![expected](expected.png)

