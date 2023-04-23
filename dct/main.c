#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "dct.h"

/* Bitrate of the project */
#define RATE (44100)
/* Lowest frequency we want to deal with */
#define LOWTH (100)

#define BLOCK ((int)(RATE / LOWTH))

static double buf_d[BLOCK];
static double buf_t[BLOCK];

static char cbuf[BLOCK];


/*
 * Component index in the coefficient vector
 */
int
component (int hz) {
    return BLOCK / (hz / LOWTH);
}

/*
 * Low-pass filter (sharp)
 */
void
lpf (int hz) {
    int i;
    for (i = component(hz); i != BLOCK; i++) {
        buf_t[i] = 0.0f;
    }
}

void
dsp (void) {
    lpf(1000);
}


int main (int argc, char** argv) {
    int fi;
    int fo;
    int blocks = 0;
    size_t bytes = 1;

    int i;

    fi = open("./sample.raw", O_RDONLY);
    fo = open("./out.raw", O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR);

    while (bytes) {
        bytes = read(fi, cbuf, BLOCK);
        if (bytes != BLOCK) {
            printf("(!!!) block: %i\n", blocks);
        }
        blocks++;
        if (!(blocks % 1024)) {
            printf(".\n");
        }

        for (i = 0; i != BLOCK; i++) {
            buf_d[i] = (double)cbuf[i];
        }

        dct(buf_d, buf_t, BLOCK);
        dsp();
        idct(buf_t, buf_d, BLOCK);

        for (i = 0; i != BLOCK; i++) {
            cbuf[i] = (char)buf_d[i];
        }
        write(fo, cbuf, BLOCK);

    }
    close(fo);
    close(fi);

    return 0;
}
