#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>

#define DP (8)

#define DIVVER (1)

static int math_lookup_t[] = {
    0, 90, 127, 90, 0, -90, -127, -90,
    0, 90, 127, 90
};

const int *sin_t = &(math_lookup_t[0]);
const int *cos_t = &(math_lookup_t[2]);

static int i_in[] = {0,-127,0,0,127,0,0,0};
static int q_in[] = {0,0,0,0,0,0,0,0};

static int i_out[DP];
static int q_out[DP];

void
dft8 (int *i_in, int *q_in, int *i_out, int *q_out) {
    int n;
    int k;

    for (n = 0; n != DP; n++) {
        int *i_p = i_in;
        int *q_p = q_in;

        *i_out = 0;
        *q_out = 0;

        for (k = 0; k != DP; k++) {
            int ang = (n * k) % 8;
            *i_out += ((*i_p * cos_t[ang]) + (*q_p * sin_t[ang]));
            *q_out += ((-(*i_p) * sin_t[ang]) + (*q_p * cos_t[ang]));
            i_p++;
            q_p++;
        }
        *i_out /= DP * DIVVER;
        *q_out /= DP * DIVVER;
        i_out++;
        q_out++;
    }
}

void
ift8 (int *i_in, int *q_in, int *i_out, int *q_out) {
    int n;
    int k;

    for (n = 0; n != DP; n++) {
        int *i_p = i_in;
        int *q_p = q_in;

        *i_out = 0;
        *q_out = 0;

        for (k = 0; k != DP; k++) {
            int ang = (n * k) % 8;
            *i_out += ((*i_p * cos_t[ang]) - (*q_p * sin_t[ang]));
            *q_out += ((*i_p * sin_t[ang]) + (*q_p * cos_t[ang]));
            i_p++;
            q_p++;
        }
        *i_out /= DP * DIVVER;
        *q_out /= DP * DIVVER;
        i_out++;
        q_out++;
    }
}


void
printout (int *i, int *q) {
    int n;
    for (n = 0; n != DP; n++) {
        printf("%i + j%i\n", i[n], q[n]);
    }
    printf("\n");
}


int
main (int argc, char** argv) {

    ift8(i_in, q_in, i_out, q_out);
    printout(i_out, q_out);
    dft8(i_out, q_out, i_in, q_in);
    printout(i_in, q_in);

    return 0;
}


