# One-port fixture de-embedding

This little script takes a complex impedance, and de-embeds a given fixture (e.g. a transmission line, characterized by its characteristic impedance and the phase angle) from it. Useful for determining the impedance of a network behind a known fixture.

![deembed](deembed.png)

First, we need to reconstruct the ABCD matrix of the entire system. Since we only have a single-port measurement but want to build the ABCD matrix of a 2-port network, we pretend that the other port is there, but it's terminated and the two ports don't interact. Also, -for the sake of simplified de-embedding maths- we assume that the network we're working with is on port 2 (mirrored).

![deembedmirror2](deembedmirror2.png)

As a first step, we establish S22 from the measured impedance (Z22). Then we build up our ABCD matrix of the *entire system* with S22, assuming that all the other S-parameters (the ones involving port 1) are zero.

As a next step, we build up the ABCD matrix of the *fixture* - which in this case is a modeled ideal transmission line.

Finally, we de-embed the fixture from the system by the virtue of a simple matrix division - which is possible due to the fact that we used the *"mirrored"* image of the network, i.e. we assumed that the ABCD matrix of the fixture was cascaded together with the inner network, resulting in the impedance we've measured with the VNA.

