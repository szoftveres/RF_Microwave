## Pillbox Vacuum Window, 81-86 GHz, WR12 waveguide

[OpenEMS script](pillbox.m)

After determining the window material and stock to be used (10 mil thick Alumina in this case), the most important dimension is the length of the circular waveguide, which contains exactly 3/2λ of the guided wave at center frequency, including the wave portion traveling inside the window. Due to the window being made of material that has higher dielectric constant than air (or vacuum) and the wavelength being shorter in it, the overall circular waveguide length is slightly shorter than 3/2λ.

Ideally the window rim with the surrounding metal should form a dielectric 1/4λ choke, however due to practical (mounting and durability) reasons the rim is sized to make a 3/4λ choke, allowing more window material to be embedded into the metal frame.

![pb1](pillbox_1.png)

![pb2](pillbox_2.png)

![pbsim](pillbox_sim.png)
