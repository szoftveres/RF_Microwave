## Experimental FMCW Radar

The purpose of this experimental radar was to test out an easy-to-build, fully DIY (RF amplifiers, VCO, beamforming antennas, splitters, etc..) RF system as well as simple digital signal processing algorithms in GNU Octave.

### Architecture

Architecturally the radar is conventional (standard), operating in the 902-928 MHz frequency band. The analog (baseband and sweep sync) signals are fed into a stereo audio line-in interface of a PC, recorded and saved as 48kHz sample rate stereo WAV file. The WAV file is then processed by the [processing script](https://github.com/szoftveres/RF_Microwave/tree/main/radar/fmcw_process.m).

![arch](arch.png)

### Components

#### Ramp waveform generator

The ramp waveform generator produces periodic linear ramp waveforms, and a sync signal, which is being recorded and used by the DSP algorithm to detect the start- and stop of each sweep. The ramp amplitude (VCO tuning voltage level) control is also on this board, setting the FM sweep width of the radar.

![ramp_gen_schem](ramp_gen_schem.png)

Ramp and sync signals:

![ramp_waveform](ramp_waveform.jpg)

#### VCO

Ideally, the VCO has to be able to tune strictly linearly across the frequency range, following the tuning voltage, and provide flat power level across the band. Neither of these requirements can be achieved with a simple VCO like this one, however the fact that we're using only a small portion of the tuning range gives acceptable results.

The on-board trimmer (RV1) sets the center frequency of the oscillator anywhere between 800 MHz and 1 GHz, the microstrip coupler is designed for roughly 12dB coupling factor.

![VCO_schem](VCO_schem.png)

![VCO_photo](vco_photo.jpg)

#### Driver amplifier

The driver amplifier amplifies the signal from the VCO, to where it's sufficient to drive the mixer through the Wilkinson splitter - the Mini-Circuits ADE-5+ mixer used in this project requires +7 dBm LO power, hence the driver amplifier has to be able to provide +10 dBm at its output. The other branch of the Wilkinson splitter either goes directly to the Tx antenna, or can drive a PA for more Tx output power.

The driver amplifier is essentially a balanced-amp version of the Rx antenna LNA (discussed below), it's covered on a [common design page](https://github.com/szoftveres/RF_Microwave/tree/main/Amplifier/cascode).

![driver](https://github.com/szoftveres/RF_Microwave/blob/main/Amplifier/cascode/balanced_photo.jpg)

#### Antennas

There are some special requirements towards the antennas. First, ideally we'd want the radar to "see" at a narrow angle (because its image is 1-dimensional), which calls for a beamforming antenna. Then, good isolation between the transmitting- and receiving antennas is critical, the relatively high Tx RF levels must not be picked up by the nearby Rx antenna and overdrive the receiver LNA, mixer and analog front-end.

The antennas used here are two-element [DIY PCB Yagi](https://github.com/szoftveres/RF_Microwave/tree/main/em_antenna/915_pcb_yagi) arrays, spaced 1/2 λ apart, providing 60° beam width and better than 12dB front-to-back ratio.

The Tx and Rx bays are mounted on rods with their vertical nulls pointing toward each other; measured isolation between the two bays is better than -40 dB with this arrangement, only 60 cm apart from each other:

![antenna_assembly](antenna_assembly.jpg)

Simulated array factor and far-field pattern (OpenEMS) for one array:

![array_factor](array_factor.png)

![array_pattern](antenna_array_pattern.png)

#### Rx Antenna LNA

The role of the receiver antenna LNA is to overcome the noise contributions of the mixer, as well as to maintain linear amplification at the presence of a nearby powerful Tx signal source.

The design is covered in [this page](https://github.com/szoftveres/RF_Microwave/tree/main/Amplifier/cascode) (the above mentioned driver amplifier is also discussed on this page).

A long, lossy cable between the antenna and the LNA can degrade the Rx path noise figure due to cable losses, therefore the LNA features an on-board bias-tee, and is physically connected directly to the antenna RF output. Power is supplied through the coax cable via another bias-tee at the radar electronics side.

![lna](https://github.com/szoftveres/RF_Microwave/blob/main/Amplifier/cascode/cascode_photo.jpg)

#### Analog frontend

The reflected signal experiences spherical expansion (a.k.a. Friis path loss) twice during its time in flight (first when on the way to the target and the second time when reflected back); consequently, moving a target twice as far away reduces the magnitude of the reflected signal to 1/16th of its original level. This has to be compensated for, distant objects should show up with the same intensity as nearby objects on the radar image. Also, feeding the baseband directly to the ADC without any pre-compensation would severely limit the magnitude (ADC quantizing) resolution of the faint echo signals from distant objects.

Distance translates directly to baseband frequency, so compensation can easily be implemented with a 2nd order (40 dB/decade) high-pass (pre-emphasis) filter on the baseband frequencies.

The analog frontend is also the main gain block before the ADC, the RF LNA is mainly used to overcome the noise contribution of the mixer.

![analog_frontend_schem](analog_frontend_schem.png)

### Build

Components mounted on an aluminum backplane:

![boards_annotated](boards_annotated.jpg)

#### Basic Parameters

The sweep periodicity is set to approximately 100 Hz (10ms period), with the sweep span being roughly 30 MHz. This gives a 3 GHz/sec chirp steepness. With given c (speed of light), the different target distances and associated baseband frequencies can easily be calulated:

15m distance -> 30m roudtrip -> 100ns time of fligt -> 300Hz baseband

150m distance -> 300m roudtrip -> 1us time of flight -> 3kHz baseband

The processing script gathers samples and runs FFT on the full length of each sweep, hence the FFT bucket resolution is 100Hz, giving a physical resolution of 5m / FFT bucket to this radar (the radar is only sensitive to the magnitude of the baseband frequencies and ignores the phase).
The audio interface can reliably record frequencies up to at least ~15kHz, which sets the analog bandwidth limited range to ~750 m (1/2 mile).

#### Estimating the noise- and ADC limited range

First some assumptions have to be made about the target - for simplicity, let's assume that it can be modeled as an antenna with +9 dBi gain (same as what this radar is using for Tx and Rx antennas) that reflects 100% of its received power back. Tx power of the radar is +7 dBm; approximately 20 kHz bandwidth is needed for analog processing and the LNA has approximately 2.5 dB noise figure; this brings the minimum noise limited signal level at the input of the LNA to approximately -128 dBm at room temperature. Both (Tx and Rx) antennas have approximately +9 dBi gain. Calculating with Friis path loss for each path (out and return) gives a noise-limited range of approximately 500m.

The ADC of the audio interface is recording with 16 bit resolution. Relative to 1Vpp full signal level, the magnitude of one symbol out of 65536 is approximately 15 uVpp, which translates to -92 dBm signal level - this is the minimum detectable signal level by the ADC. When the previously calculated, -128dBm (noise-limit minimum level) signal reaches the LNA, it gets amplified sufficiently by the combined gain of the LNA (+18 dB) and the analog front-end (> +80 dB above 3kHz), at 7 dB mixer conversion loss, to easily surpass this level. Consequently, the ADC bit-resolution is not a factor.

### Testing and processing

Several seconds long audio recordings were made, when a vehicle was passing by on a straight residental street section.

![earth](earth.png)

The [processing script](https://github.com/szoftveres/RF_Microwave/tree/main/radar/fmcw_process.m) detects each sweep by the sync signal, and performs FFT on the samples. The Y-axis in resulting 2-dimensional image is the distance, the X-axis is the time, and the color represents signal intensity.

![car_with_noise](car_with_noise.png)

The image is mostly showing static frequency components (horizontal lines) from stationary reflecting objects (nearby buildings, cars on driveways, etc..).

These components can be characterized (e.g. by taking an initial measurement, or by calculating an average value for each component throughout the X-axis, etc..) and removed, resulting in an image that better highlights moving objects:

![car_without_noise](car_without_noise.png)

