## Low Noise Amplifier for 5.8 GHz

![meas_pic](meas_pic.jpg)

### Design

![schem](schem.png)

The design was created around the BFP640ESD SiGe BJT transistor; this device has an ft of ~46 GHz, and consequently low noise figure at the intended frequency. The target PCB stackup is the OSHpark 4-layer service. The small-signal S-parameters of the transistor are published (up to 10 GHz), which makes it possible to simulate the design first:

![sim](sim.png)

The amplifier is unstable at low frequencies when the upper part of the load stub is fully RF grounded, therefore grounding is achieved in two steps: first, a radial stub creates an RF ground for 5.8 GHz, then the low-frequency grounding of the entire circuit is done with high-value capacitors behind a 33 Ω resistor. This resistor acts as a damper for the lower frequencies, hence the amplifier becomes stable. The 33 Ω resistor also serves as an auto-bias load.

### Performance

Gain is 11.5 dB and S11 is quite broad band and satisfactory. From a 3.3V power supply, the current consumption is set to 10mA. The most important RF performance parameters remain mostly unchanged between 2.7V and 4V power supply voltages.

S-parameter (DIY [VNA](https://github.com/szoftveres/RF_instruments/tree/main/vna)) measurement:

![spar_meas](spar_meas.png)

