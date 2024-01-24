This [script](complexmatching.py) does multiple things:
* For a given complex impedance (given in a conventional, * *series* * *a + jb* form) it calculates the equivalent *parallel* components.
* It calculates the characteristic impedance of a λ/4 impedance transformer, that would convert the complex impedance in such a way, so that the equivalent *parallel* impedance would have a real part of 50Ω. The benefit of this is that the remaining reactance can easily be resonated out with its complex conjugate reactance, resulting in purely ohmic 50Ω impedance.

The λ/4 impedance transformer transforms the *magnitude* of the complex impedance, along with converting any reactance to its complex conjugate. This way, e.g. a complex impedance with a capacitive component can be transformed to look like inductive, which then can be easily resonated out by adding capacitance.

An example:
A MOSFET or BJT is typically seen as capacitive, with some resistive component. Knowing the complex input impedance, this script can calculate the matching network (λ/4 impedance transformer and capacitance) to perfectly match the input of these devices to 50Ω.


![complex](complexmatching2.png)


