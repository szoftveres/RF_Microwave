## Prototyping an FMCW Radar

### Architecture

The radar operates in the 902-928 MHz frequency band and uses mostly DIY components (including the antennas). The analog signals (IF and sweep sync) are fed into a stereo audio line-in interface of a PC and is recorded and saved as 48kHz sample rate stereo WAV file. The WAV file is then processed by the [processing script](https://github.com/szoftveres/RF_Microwave/tree/main/radar/fmcw_process.m).


The sweep periodicity is set to approximately 100 Hz, with the sweep span being roughly 30 MHz. This gives a 3 GHz/sec chirp steepness. With c (speed of light) being approximately 300000 km/sec, the different target distances and associated IF frequencies can easily be calulated:

15m distance -> 30m roudtrip -> 100ns time of fligt -> 300Hz IF

150m distance -> 300m roudtrip -> 1us time of flight -> 3kHz IF

Since we're only detectig the magnitude of the IF frequencies (ignoring the phase) at approximately 100Hz steps, the theoretical resolution is 5m. 
The audio interface can reliably record frequencies up to at least ~15kHz, which gives a theoretical range of ~750 m (~ 1/2 mile).

### Components

#### VCO

The VCO is a Colpitts type varicap-tuned dsicrete transistor oscillator with buffered output, designed to operate between roughly 800MHz and 1GHz. Its output level is relatively flat across the band, at +2dBm.

![VCO_schem](VCO_schem.png)

#### Ramp waveform generator

The ramp generator is a Miller-integrator & Scmitt-trigger based circuit that produces a linear sawtooth waveform, as well as a sync signal that is used by the processing algorithm to detect the sweep starts and ends.

![ramp_gen_schem](ramp_gen_schem.png)

#### Analog frontend

Since received RF signal experiences spherical expansion (Friis path loss) twice during its time in flight (once when transmitted by the transmitter antenna, and once when reflected back from a small, point-like object), the reflected signal strength of an object that was repositioned at double distance is only 1/16 of what the radar would receive when the object was at 1/2 distance. This has to be compensated for.
Luckily, since increasing distance translates directly to increasing IF frequency, a compensation can easily be implemented in the analog frontend, in the form of a 2nd order (40 dB/decade) high-pass filter.

![analog_frontend_schem](analog_frontend_schem.png)


