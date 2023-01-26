#!/usr/bin/python

import math

## Series impedance
real = 17.689
imag = -5.63

f = 1.5e9
Z0 = 50.0


def print_impedance(real, imag):
    if imag < 0.0:
        print("   Complex impedance: {} - j{}".format(real, abs(imag)))
    else:
        print("   Complex impedance: {} + j{}".format(real, imag))


def omega(freq):
    return 2.0 * 3.1415926535 * freq



def q(real, imag):
    return abs(imag) / real

###
# Given a reactance and frequency, calculate the capacitance- or inductance
###
def imag_to_part(imag, freq):
    w = omega(freq)
    if imag < 0.0:
        print("   C = {}pF".format((1.0 / (abs(imag) * w)) * 1e12))
    else:
        print("   L = {}nH".format((imag / w) * 1e9))
        
###
# This function gets a complex series impedance in a R + Xj format and
# calculates the equivalent parallel Resistance + Reactive impedance
###
def solve(real, imag, freq):
    q2 = pow(q(real, imag), 2)
    print_impedance(real, imag)
    print("   Series")
    print("   R = {}ohm".format(real))
    imag_to_part(imag, freq)
    print()

    print("   Parallel")
    print("   R = {}ohm".format(real * (1.0 + q2)))
    t_imag = imag * (1.0 + (1.0 / q2))
    imag_to_part(t_imag, freq)
    print("      resonating reactance")
    imag_to_part(-t_imag, freq)
    print()

solve(real, imag, f)


###
# Here we calculate the complex impedance that we would see, if we attached
# a quarter-wave impedance transformer, that transforms in such a way so that the
# resulting impedance in a parallel format would have a real part equal to Z0
# In this format, we can easily calculate the needed complex reactance to resonate
# the circuit into a purely Z0 resistive impedance.
###
real2 = Z0 / (1 + pow(q(real, imag), 2))
imag2 = -imag * (real2 / real)


###
# Calculate the characteristic impedance of the actual quarter-wave transformer.
# The quarter-wave transformer transforms the magnitude of the complex impedance in such a way
# so that the Q (the ratio of X/R) of the original impedance is preserved.
###
Rt = math.sqrt(math.sqrt(pow(real,2)+pow(abs(imag),2)) * math.sqrt(pow(real2,2)+pow(abs(imag2),2)))
print()
print("   Rquarterwave = {}ohm".format(Rt))
print()

solve(real2, imag2, f)


