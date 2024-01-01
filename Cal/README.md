## 1-port 3-term calibration

[Calculating](calibration.m) the actual S-parameters of a DUT network, by the virtue of deemedding an "error matrix" from it (e.g. test fixture or cabling). The error matrix elements are obtained by measuring an open, short and load standards and calculating the error coefficients. The actual maths are [here](https://github.com/szoftveres/RF_Microwave/tree/main/RFlib/p1cal.m).

The setup includes a 50ft long coax cable and a 1dB attenuator on port 1. All measurements (DUTs and Cal standards) were taken without any calibration applied on the VNA.

![setup](setup.jpg)

### Raw measurements

Open:

![open_raw](open_raw.png)

Short:

![short_raw](short_raw.png)

Load:

![load_raw](load_raw.png)

### Calculated error matrix calibration applied

Open:

![open_calibrated](open_calibrated.png)

Short:

![short_calibrated](short_calibrated.png)

Load:

![load_calibrated](load_calibrated.png)

