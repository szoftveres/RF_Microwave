#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/*
    Three-point tracking calculator
https://www.vintage-radio.info/download.php?id=485

Calculates the high-side components of a dual-gang capacitor
tuning system for a given low-side components for the best
three-point IF tracking.

                 -.
            Ctrim/|
              ||/
       +------||-------+
       |     /||       |  Cpad
       |               |   ||
       +--->||---||<---+---||---+
       |    Varicaps       ||   |
       |                        |
 ------+---       L       ------+------
           \_/\_/\_/\_/\_/
*/


const double IF = 0.455d; /* IF in MHz */
const double allowed_deviation = 0.00025d; /* Deviation from IF in MHz at the trimming points */

double l_high;
double c_high_pad;
double c_high_trim;

double l_low = 250000.0d;
double c_low_pad = 1500000000000000.0;
double c_low_trim = 25.0d;


void dump_elements(void) {
    printf("\nIF = %.3fMHz,\n"
           "l_high: %.1fnH, c_high_pad:%.1fpf c_high_trim:%.1fpf\n"
           "l_low:  %.1fnH, c_low_pad:%.1fpf c_low_trim:%.1fpf\n",
           IF,
           l_high, c_high_pad, c_high_trim,
           l_low, c_low_pad, c_low_trim);
}


double replus (double a, double b) {
    return (1.0d / ((1.0d / a) + (1.0d / b)));
}

double MHz (double pF, double nH) {
    return (1.0d / (3.1415926d * 2 * sqrt((pF * 1e-12) * (nH * 1e-9)))) / 1e6;
}

double freq (double varicap, double l, double c_pad, double c_trim) {
    return MHz(replus(varicap + c_trim, c_pad), l);
}

void dump_res(double varicap_h, double varicap_l) {
    double varicap;

    printf("\n\n");
    printf("varicap (pF)    high_f (MHz)     low_f (MHz)         tracking (kHz)         Q\n\n");
    for (varicap = varicap_h; varicap > (varicap_l * 0.99d); varicap /= 1.23d) {
        double f_low;
        double f_high;
        double f_diff;

        f_low = freq(varicap, l_low, c_low_pad, c_low_trim);
        f_high = freq(varicap, l_high, c_high_pad, c_high_trim);

        f_diff = (IF - (f_high-f_low + 0.0005d));
        printf("%.1f            %.2f            %.2f                %.1f                %.1f\n",
                varicap,        f_high,      f_low,           f_diff * 1000.0d,           sqrt((f_low/f_diff)*(f_low/f_diff)));
    }
}

int check (double varicap, double* correction_factor) {
    int rc = 0;
    double f_osc = freq(varicap, l_high, c_high_pad, c_high_trim);
    double f_mod = freq(varicap, l_low, c_low_pad, c_low_trim);
    double f_mix = f_osc - f_mod;

    if (f_mix < 0.0d) {
        *correction_factor = 0.4d;
        rc = 1;
    } else if ((f_mix < (IF - allowed_deviation)) || (f_mix > (IF + allowed_deviation))) {
        *correction_factor = (f_osc / (f_mod + IF));
        rc = 1;
    }
    return rc;
}

int trim (double *element, double varicap) {
    double correction_factor = 1.0d;
    int trimming = 1;
    int rc = 0;
    int iterations_left = 20000;
    while (trimming) {
        iterations_left--;
        trimming = check(varicap, &correction_factor);

        if (trimming != 0) {
            rc = 1;
            *element *= (correction_factor);
        }
        if (!iterations_left) {
            dump_elements();
            dump_res(varicap, varicap);
            printf("\nERROR: not converged, element %.1f correction_factor %.5f \n", *element, correction_factor);
            exit(1);
        }
    }
    return rc;
}

int main (int argc, char** argv) {
    int iterations = 0;
    l_high = l_low;
    c_high_pad = c_low_pad;
    c_high_trim = c_low_trim;

    const double varicap_h = 365.0d;
    const double varicap_l = 10.0d;
    const double varicap_m = (((varicap_h - varicap_l) / 6.2832d) + varicap_l);

    double varicap;

    while (1) {
        if (!(iterations % 250)) {
            printf(".");
        }
        iterations++;
        /*** MID ***/
        if (trim(&l_high, varicap_m)) {
            continue;
        }

        /*** LO ***/
        if (trim(&c_high_pad, varicap_h)) {
            continue;
        }

        /*** HI ***/
        if (trim(&c_high_trim, varicap_l)) {
            continue;
        }
        break;
    }

    printf("\nIterations : %d\n", iterations);
    dump_elements();
    dump_res(varicap_h, varicap_l);

    return 0;
}

