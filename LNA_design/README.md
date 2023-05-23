# LNA design

## Narrow-band LNA design for 915MHz, using BFR91A BJT transistor and stub-matching.

### The design:

The transistor is biased to ~4.5mA (minimum noise figure, according to the datasheet) and both ports are simulateneously matched with parallel open stubs. Gain is on the order of ~10dB with good (but narrow-band) input match at 915MHz (ISM mid-band).

![screen](screen.png)

### The build:

![pcb1](pcb1.jpg)
![pcb2](pcb2.jpg)

### Results after tuning:

Simulated:

![expected](expected.png)

Measured:

![vna](vna.jpg)
