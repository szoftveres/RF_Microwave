#include <stddef.h>
#include <math.h>
#include <stdint.h>
#include <stdlib.h>



/**
 * Transform a (double) type vector with (len) elements
 */
int
dct (double src[], double dst[], size_t len) {
    double factor;
    size_t i;
    size_t j;

    if (!src || !dst) {
        return 1;
    }

    factor = M_PI / (double)len;
    for (i = 0; i != len; i++) {
        double sum = 0.0f;
        for (j = 0; j != len; j++) {
            sum += src[j] * cos(((double)j + 0.5f) * (double)i * factor);
        }
        dst[i] = (sum / (double)len) * 2.0f;
    }
    return 0;
}


/**
 * Get in-between points -indexed by (point)- during inverse transform
 * Useful for curve-fitting interpolation
 */
double
get_point (double src[], size_t len, double point) {
    double factor;
    size_t j;
    double sum = src[0] / 2.0f;

    factor = M_PI / (double)len;
    for (j = 1; j != len; j++) {
        sum += src[j] * cos((point + 0.5f) * (double)j * factor);
    }
    return sum;
}


/**
 * Inverse transform a (double) type vector with (len) elements
 */
int
idct (double src[], double dst[], size_t len) {
    size_t i;

    if (!src || !dst) {
        return 1;
    }

    for (i = 0; i != len; i++) {
        dst[i] = get_point(src, len, (double)i);
    }
    return 0;
}


