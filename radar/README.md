## FMCW Radar

Prototyping and Testing

### Architecture

The radar operates in the 902-928 MHz frequency band and uses mostly DIY components (including the antennas). The analog signals (IF and sweep sync) are fed into a stereo audio line-in interface of a PC and is recorded and saved as 48kHz sample rate stereo WAV file. The WAV file is then processed by the [processing script](https://github.com/szoftveres/RF_Microwave/tree/main/radar/fmcw_process.m).

![arch](arch.png)

The sweep periodicity is set to approximately 100 Hz, with the sweep span being roughly 30 MHz. This gives a 3 GHz/sec chirp steepness. With c (speed of light) being approximately 300000 km/sec, the different target distances and associated IF frequencies can easily be calulated:

15m distance -> 30m roudtrip -> 100ns time of fligt -> 300Hz IF

150m distance -> 300m roudtrip -> 1us time of flight -> 3kHz IF

Since we're only detectig the magnitude of the IF frequencies (ignoring the phase) at approximately 100Hz steps, the theoretical resolution is 5m. 
The audio interface can reliably record frequencies up to at least ~15kHz, which gives a theoretical range of ~750 m (1/2 mile).

### Components

#### VCO

The VCO is a Colpitts type varicap-tuned dsicrete transistor oscillator with buffered output, designed to operate between roughly 800MHz and 1GHz. Its output level is relatively flat across the band, at +2dBm.

![VCO_schem](VCO_schem.png)

![sweep_spectrum](sweep_spectrum.jpg)

#### Ramp waveform generator

The ramp generator is a Miller-integrator & Scmitt-trigger based circuit that produces a linear sawtooth waveform, as well as a sync signal that is used by the processing algorithm to detect the sweep starts and ends.

![ramp_gen_schem](ramp_gen_schem.png)

![ramp_waveform](ramp_waveform.jpg)

#### Analog frontend

Since received RF signal experiences spherical expansion (Friis path loss) twice during its time in flight (once when transmitted by the transmitter antenna, and once when reflected back from a small, point-like object), the reflected signal strength of an object that was repositioned at double distance is only 1/16 of what the radar would receive when the object was at 1/2 distance. This has to be compensated for.
Luckily, since increasing distance translates directly to increasing IF frequency, a compensation can easily be implemented in the analog frontend, in the form of a 2nd order (40 dB/decade) high-pass filter.

![analog_frontend_schem](analog_frontend_schem.png)

#### Driver amplifier and Antenna LNA

The driver amplifier is a [DIY balanced amplifier](https://github.com/szoftveres/RF_Microwave/tree/main/Amplifier/cascode), capable of delivering +10 dBm into the Wilkinson splitter - the Mini-Circuits ADE-5+ mixer requires +7 dBm LO power.

![driver](https://github.com/szoftveres/RF_Microwave/blob/main/Amplifier/cascode/balanced_photo.jpg)

The antenna amplifier LNA is the [DIY cascode antenna amplifier](https://github.com/szoftveres/RF_Microwave/tree/main/Amplifier/cascode), which has an integrated bias-tee and can be powered through the RF coax cable.

![lna](https://github.com/szoftveres/RF_Microwave/blob/main/Amplifier/cascode/cascode_photo.jpg)

#### Antennas

There are some special requirements towards the antennas. On one hand, the radar can only look ahead at a narrow beam and its image is 1-dimensional, which calls for a beamforming antenna. On the other hand, good isolation between the transmitting- and receiving antennas is critical, the relatively high RF levels from the nearby transmitting antenna must not reach and overdrive the receiver LNA, mixer and analog front-end.

The antennas used here are two-element [DIY PCB Yagi](https://github.com/szoftveres/RF_Microwave/tree/main/em_antenna/915_pcb_yagi) arrays, spaced 1/2 λ apart and fed through a Wilkinson splitter. Since the two elements interact with each other, their combined reduced feedpoint impedance is re-matched with L-match at each dipole elements. This array arrangement has field strength nulls at perpendicular (90°) angles, as well as a 60° beam pattern ahead of the antenna; the measured isolation is on the order of -40 dB when the antennas are side-by-side, only 1 m apart from each other.


Far-field patterns:

![array_factor](array_factor.png)

![array_pattern](antenna_array_pattern.png)


### Testing and processing

The initial testing was done on a straight section of street with some car traffic. The analog signals of the continuously running radar were fed into a PC, and several audio recordings were made when a vehicle passed by.

![earth](earth.png)

The processing script detects the sweeps and performs FFT on the samples of each sweep. The resulting 2-dimensional color map shows objects at various distances (Y-axis) as a function of time (X-axis).

![car_with_noise](car_with_noise.png)

Since the environment has a lot of stationary reflecting objects (buildings, etc..), the radar image is mostly showing static frequency components (horizontal lines).

These components can be characterized (e.g. by taking an initial measurement, or by calculating an average value for each component throughout the plot, etc..) and subtracted from each sweep, resulting in an image that better highlights moving objects.

![car_without_noise](car_without_noise.png)

