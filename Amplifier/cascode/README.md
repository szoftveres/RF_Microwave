## Cascode BJT LNA for 915MHz

With the input T-match tuned for best NF:

![cascode_schem](cascode_schem.png)

### Noise sources

Besides non-ideal (lossy) inductors in the input T-matching network, the use of electrically short microstrip stub as shunt capacitance - being built on lossy PCB material and being at the highest impedance point of the matching network - introduces around 0.6dB NF degradation versus an ideal (lossless) 1.5pF capacitor.

The same circuit re-arranged for PI-match input, showing 0.4dB NF improvement:

![pi-match](pi-match.png)  

### Non-linearity

Simulated P1DBout is around +6dBm; the 2nd and 3rd harmonics are observable but are heavily suppressed, due to the output matching network being tuned to the fundamental.

![linearity](hb2.png)  

### Prototyping, build and measurements

Prototype, with stubs:
![lnapcb](lnapcb.jpg)


Build, with output pad (4dB) and integrated bias-tee:

![schematic_cascode](schematic_cascode.png)

![cascode_photo](cascode_photo.jpg)

![lna_sparams](lna_sparams.png)

Gain: +18.17 dB, P1dBin: -11.8 dBm, OP1dB: +5.37 dBm 
![lna_pwrsweep](lna_pwrsweep.png)








