## FMCW Radar

### Architecture

The radar operates in the 902-928 MHz frequency band and uses mostly DIY components (including the antennas). The analog (baseband and sweep sync) signals are fed into a stereo audio line-in interface of a PC, recorded and saved as 48kHz sample rate stereo WAV file. The WAV file is then processed by the [processing script](https://github.com/szoftveres/RF_Microwave/tree/main/radar/fmcw_process.m).

![arch](arch.png)

### Components

#### VCO

Requirements towards the VCO is relatively linear tuneability and flat power output across the band. The design in this radar is a dsicrete transistor Colpitts type varicap-tuned oscillator with buffered output. An on-board trimmer provides 0-5V tuning voltage, this sets the center frequency of the oscillator oscillator from approximately 800 MHz and 1 GHz; the external FM modulation comes from the ramp waveform generator. The required 30 MHz deviation is a fraction of the full tuning range of the VCO, ensuring good linearity. Output level is relatively flat across the band, at +2dBm. The output is lightly coupled and buffered, hence following stages have no pulling effect on the VCO.

![VCO_schem](VCO_schem.png)

![VCO_photo](vco_photo.jpg)

#### Ramp waveform generator

The ramp waveform generator needs to produce linear ramp waveforms, and a sync signal, which indicates the start- and stop of each sweep. This is done by a Miller-integrator - Scmitt-trigger duo circuit, implemented with a single LM324 opamp, the ramp and sync signals are taken from different stages of the circuit. The ramp amplitude control is also on this board, the amplitude determines the FM deviation of the radar.

![ramp_gen_schem](ramp_gen_schem.png)

Ramp and sync signals:

![ramp_waveform](ramp_waveform.jpg)

#### Analog frontend

The reflected signal experiences spherical expansion (a.k.a. Friis path loss) twice during its time in flight (first when on the way to the target and the second time when reflected back); consequently, moving a target twice as far away reduces the magnitude of the reflected signal to 1/16th of its original level. This has to be compensated for, distant objects on the radar image should show up with the same intensity as nearby ones.
Distance translates directly to baseband frequency, so compensation can easily be implemented with a 2nd order (40 dB/decade) high-pass filter, implemented in the analog frontend.

The analog frontend is also the main gain block before the ADC, the RF LNA is mainly used to overcome the noise contribution of the mixer.

![analog_frontend_schem](analog_frontend_schem.png)

#### Antenna LNA

The role of the antenna LNA is to overcome the noise contributions of the mixer, the design is covered in [this page](https://github.com/szoftveres/RF_Microwave/tree/main/Amplifier/cascode). The LNA has an on-board bias-tee, which makes it suitable for being placed right after the antenna and powered through the RF coax cable - this helps eliminating RX path noise figure degradation due to cable losses.

![lna](https://github.com/szoftveres/RF_Microwave/blob/main/Amplifier/cascode/cascode_photo.jpg)

#### Driver amplifier

The driver amplifier amplifies the signal from the VCO, to where it's sufficient to drive the mixer through the Wilkinson splitter - the Mini-Circuits ADE-5+ mixer used in this project requires +7 dBm LO power, hence the driver amplifier has to be able to provide +10 dBm at its output. The other branch of the Wilkinson splitter either goes directly to the Tx antenna, or can drive a PA for more Tx output power.
The driver amplifier is essentially a balanced-amp version of the previously discussed antenna LNA and it's covered on the [same design page](https://github.com/szoftveres/RF_Microwave/tree/main/Amplifier/cascode)

![driver](https://github.com/szoftveres/RF_Microwave/blob/main/Amplifier/cascode/balanced_photo.jpg)

#### Antennas

There are some special requirements towards the antennas. On one hand, the radar can only look ahead at a narrow beam and its image is 1-dimensional, which calls for a beamforming antenna. On the other hand, good isolation between the transmitting- and receiving antennas is critical, the relatively high Tx RF levels must not be picked up by the nearby Rx antenna and overdrive the receiver LNA, mixer and analog front-end.

The antennas used here are two-element [DIY PCB Yagi](https://github.com/szoftveres/RF_Microwave/tree/main/em_antenna/915_pcb_yagi) arrays, spaced 1/2 λ apart and fed through Wilkinson-combiners. Due to proximity, the two elements within one array mutually interact with each other, reducing the feedpoint impedance - it is re-matched with L-match at each antenna element.

The arrays have field strength nulls at perpendicular (90°) angles, as well as a 60° beam width ahead of the antenna. Measured isolation between the Tx and Rx antennas is on the order of -40 dB when the antennas are side-by-side, only 60 cm apart from each other:

![antenna_assembly](antenna_assembly.jpg)

Simulated array factor and far-field pattern for one array:

![array_factor](array_factor.png)

![array_pattern](antenna_array_pattern.png)

### Build

![boards_annotated](boards_annotated.jpg)

The sweep periodicity is set to approximately 100 Hz, with the sweep span being roughly 30 MHz. This gives a 3 GHz/sec chirp steepness. With c (speed of light) being approximately 300000 km/sec, the different target distances and associated baseband frequencies can easily be calulated:

15m distance -> 30m roudtrip -> 100ns time of fligt -> 300Hz baseband

150m distance -> 300m roudtrip -> 1us time of flight -> 3kHz baseband

Theoretical resolution is 5m, the radar is only detectig the magnitude of the baseband frequencies (ignoring the phase) at approximately 100Hz steps.
The audio interface can reliably record frequencies up to at least ~15kHz, which gives a theoretical range of ~750 m (1/2 mile).

#### Estimating the noise- and ADC limited range

First some assumptions have to be made about the target - for simplicity, let's assume that it can be modeled as an antenna with +9 dBi gain (same as what this radar is using for Tx and Rx antennas) that reflects 100% of its received power back. Tx power of the radar is +7 dBm; approximately 20 kHz bandwidth is needed for analog processing and the LNA has approximately 2.5 dB noise figure; this brings the minimum noise limited signal level at the input of the LNA to approximately -128 dBm at room temperature. Both (Tx and Rx) antennas have approximately +9 dBi gain. Calculating with Friis path loss for each path (out and return) gives a noise-limited range of approximately 500m.

The ADC of the audio interface is recording with 16 bit resolution. For 1Vpp full signal level, the magnitude of one symbol out of 65536 is approximately 15 uVpp, which translates to -92 dBm signal level, which can easily be reached with the combined gain of the LNA (+18 dB) and the analog front-end (> +80 dB above 3kHz), at 7 dB mixer conversion loss.

### Testing and processing

The initial testing was done on a straight section of street - several seconds long audio recordings were made when a vehicle was passing by.

![earth](earth.png)

The [processing script](https://github.com/szoftveres/RF_Microwave/tree/main/radar/fmcw_process.m) detects each sweep (using the sync signal) and performs FFT on the samples. The resulting 2-dimensional image shows objects at various distances (Y-axis) as a function of time (X-axis).

![car_with_noise](car_with_noise.png)

The image is mostly showing static frequency components (horizontal lines) from stationary reflecting objects (nearby buildings, etc..).

These components can be characterized (e.g. by taking an initial measurement, or by calculating an average value for each component throughout the plot, etc..) and removed, resulting in an image that better highlights moving objects:

![car_without_noise](car_without_noise.png)

