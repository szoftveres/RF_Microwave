## The 915MHz design

Cascode architecture has several benefits over a single transistor; optimizing (tuning) the matching network on either side becomes a much easier task due to improved isolation of the two ports. Stability improves significantly and also more gain is achievable due to higher output impedance.

This design is optimized around inductor values that are available to purchase as discrete parts; the matching networks use electrically short microstrip lines as trimmable shunt capacitors.

Input matching is implemented with a high-Q narrow-band T-match, taking advantage of its natural filtering and band-passing effect before the first LNA stage. Output matching is implemented with an L-match; in order to improve stability, artificial resistive loss (R22, 10ohm) was added in series with the shunt capacitance (electrically short microstrip); this degenerates the Q of the matching network at the expense of slight loss of gain, without having significant effect on the noise figure.

The LNA circuit, with the input T-match tuned for best NF:

![cascode_schem](cascode_schem.png)

With the transistors used in this circuit (Philips/NXP BFR92A, ft = 5GHz), stability is not an issue at these frequencies.

### Noise sources

Besides non-ideal (lossy) inductors in the input T-matching network, the use of electrically short microstrip stub as shunt capacitance - being built on lossy PCB material and being at the highest impedance point of the matching network - introduces around 0.6dB NF degradation versus an ideal (lossless) 1.5pF capacitor.

Without compromising tunability, NF can be improved by around 0.4dB by re-arranging the input to a PI-match and moving the tunable microstrip stub to the lowest impedance point of the input matching network (base of the BJT), at the expense of lower inductor and capacitor values (more uncertainty when using discrete parts) as well as the need for a good ground via for the discrete shunt capacitor.

The same circuit with input PI-match, showing 0.4dB NF improvement:

![pi-match](pi-match.png)  

The bias point for best NF of this transistor is at around 5mA, higher bias current (e.g. for better P1DB) will start degrading the best obtainable NF. 

Also, the input matching is a tradeoff between best match vs. best obtainable NF.

## Adapting for 2.4GHz

At 2.4GHz these transistors begin showing their limitations in the form of reduced gain and increased noise figure.

![lna2g4](lna2g4.png)

With boosted (regulated) cascode topology, slight gain increase can be achieved, however stability starts becoming an issue:

![boosted](boosted.png)

