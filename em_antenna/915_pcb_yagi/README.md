# Two-element Yagi-Uda PCB antenna for the 915MHz ISM band

The goal here was to design and build a simple, cheap (PCB) but high-performance, versatile, directional antenna for DIY experiments.

![design](design.png)

![sweep](sweep.png)

### Design

The expected feedpoint impedance of a standard, resonant folded dipole is around 4 x 73 Ω (conveniently 300 Ω) if its wires are of the same width and there are no passive elements nearby. However the proximity of the passive reflector element drastically brings down the feedpoint impedance, to the point where matching to 50 Ω and simultaneously converting the feedpoint to single-ended feed using a commercial balun becomes a challenge, as well as it de-tunes the antenna. Luckily, increasing the thickness of the outer parallel wire (trace) of the driven element increases the feedpoint impedance. Finding a suitable thickness that brings the feedpoint impedance to 200 Ω makes the differential to single ended conversion as well as matching to 50 Ω an easy task, using an off the shelf 4:1 balun (Mini-Circuits TCN4-162+).

The design process started with the definition of the rough dimensions of the driven element and the reflector (~16% longer than the driven element). As a next step, the distance between the two elements were adjusted for the best front-top-back ratio while simultaneously adjustments were made to the lenght of the elements (tuning) for resonance. As the last step, the thickness of the outer parallel trace of the driven element was adjusted in order to reach the desired 200 Ω feedpoint impedance. Further small incremental adjustments were made consequtively, to further optimize the performance and parameters.

Since the antenna is made of a regular (lossy) FR4 PCB substrate, loss could be an issue with higher frequencies, however two independent simulation software showed better than 98% efficiency for this design.

Radiation pattern overlaid on the model; peak gain is on the order of 5.7dBi, front-to-back ratio is roughly 12dB.

![ptn_side](ptn_side.png)

![ptn_top](ptn_top.png)

OpenEMS simulation of E-field magnitude and element phasing:

![yagi_anim2](yagi_anim2.gif)

### Build and measurements

The build included the 4:1 SMD balun (Mini-Circuits TCN4-162+) as well as an SMA connector; resonance is a bit off from center frequency but the input return loss semms quite good within the intended band (902 MHz - 928 MHz).

![build_pcb](build.jpg)

![meas](meas.jpg)
