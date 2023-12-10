## Cascode BJT LNA

### The design:

Cascode architecture has several benefits over a single transistor; tuning the matching on either side becomes a much easier task due to improved isolation of the two ports. Stability improves significantly and also more gain is achievable due to higher output impedance.

The design is optimized around inductor values that are available to purchase as discrete parts; electrically short (trimmable length) microstrip lines are used where specific capacitor values are needed.

Input matching is implemented with a T-match; the use of electrically short microstrip stub as a shunt capacitor has a slight degradatory effect on the noise figure (around 0.6dB) due to being built on lossy PCB material and being at the highest impedance point of the matching network.
The input matching is a tradeoff between best match vs. best obtainable noise figure (in the picture).

Output matching is implemented with an L-match. The added artificial resistive loss (R22) in series with the shunt capacitor (electrically short microstrip) has beneficial effects on stability (degenerating the Q of the matching network) without having significant effects on the noise figure.

![cascode_schem](cascode_schem.png)

With the transistors used in this circuit (Philips/NXP BFR92A) stability starts becoming an issue in a cascode setup at around 2.4GHz 


