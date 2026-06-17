## Retro-style LNA for 440 MHz

The ГТ346A germanium mesa PNP RF transistor (Soviet equivalent of the Siemens AF239) was specificly developed for use in UHF TV tuners. Germanium has an inherent speed advantage over silicon due to its higher charge carrier mobility, which made germanium the preferred choice for building RF transistors until more advanced silicon processes and devices (e.g. dual-gate MOSFET) eventually arrived. 

![pic1](pic1.jpg)

![vna](vna.png)

Commercial vacuum tubes of the 1950's were useful for RF amplification service up to VHF, but became useless at UHF due to high noise figure, as a result of high interelctrode capacitances and transit-time effects - both of these adverse features can only be overcome by making the tubes physically smaller (i.e. more expensive) and the tolerances extremely tight. 

Simple UHF downconverting (self-oscillating or diode) mixers of the era were notoriously noisy (NF often as high as 10 dB), but since noise figure of the early vacuum tube amplifiers were just as high, it made no sense to build RF preamplifiers into the earliest UHF tuners, until the arrival of the very first specialized UHF vacuum tubes and RF transistors.

This style of LNA would be the first stage in a 1960's European-style UHF TV tuner, and with its ~10 dB of gain it can decimate the noise contribution of a mixer, while of course adding its own noise. According to the datasheet, at 800 MHz (which is the top of the UHF band) the NF is 7 dB at most. It gradually improves towards the lower end of the band and can get as low as 4 dB at around 400 MHz.

![schem](schem.png)

![pic2](pic2.jpg)

The LNA is powered through its output coax cable, the LED (D1) is acts as a constant voltage source and helps stabilizing the operating point over a broad range of supply voltage (4V - 12V). L1 quarter-wave transmission line choke provides DC to the emitter of the transistor while presenting high RF impedance to it. It is made of λ/4 (17.5 cm) length of copper wire, formed into a compact coil by winding it up around a small drill bit.
