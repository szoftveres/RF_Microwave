#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <limits.h>


const uint8_t hamming256[256] = {
	0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4,
	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
	4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8
};


//int polys[] = {79, 109}; // (7 [133o, 171o])
//#define CONSTRAINT (6)

int polys[] = {5, 7}; // GSM  [3 [5, 7]]
#define CONSTRAINT (2)


#define STATES (1 << CONSTRAINT)


#define CODING_RATE (sizeof(polys)/sizeof(polys[0]))

#define DATA_LEN (64)

#define HAMMING_DIST(a, b) ((int)hamming256[(((a) & ((1 << CODING_RATE) - 1)) ^ ((b) & ((1 << CODING_RATE) - 1)))])


int encode_bit (int bit, int* acc) {
    int out = 0;

    // stepping the bit into the acc
    *acc <<= 1;
    *acc |= (bit) ? 1 : 0;

    for (int k = 0; k != CODING_RATE; k++) {
        for (int kbit = 1; kbit != (1 << (CONSTRAINT + 1)); kbit <<= 1) {
            out ^= (polys[k] & *acc & kbit) ? (1 << k) : 0;
        }
    }
    return out;
}


void biterrors (char* d, int len) {
    int biterrors = 0;
    srand((unsigned int)time(NULL));
    for (int errorn = 0; errorn != len; errorn += 1) {
        int bitidx = rand() % 8;
        if (!(errorn % 2)) {
            d[errorn] ^= (1 << bitidx);
            biterrors += 1;
        }
    }
    printf("Added bit errors:%i\n", biterrors);
}


void encode (char* original, char *encoded, int original_len) {
    int acc = 0;

    int outbyte = 0;
    int outbit = 0;

    for (int byte = 0; byte != original_len; byte += 1) {
        for (int bit = 0; bit != 8; bit += 1) {
            int outw = encode_bit((original[byte] & (1 << bit)), &acc);

            for (int k = 0; k != CODING_RATE; k++) {
                encoded[outbyte] <<= 1;
                encoded[outbyte] |= (outw & (1 << k)) ? 1 : 0;
                outbit += 1;
                if (outbit == 8) {
                    outbit = 0;
                    outbyte += 1;
                }
            }
        }
    }
}


typedef struct viterbi_decoder_s {
    struct {
        int cost;
        int newcost;
        int acc;
        char data[DATA_LEN];
    } state[STATES];
} viterbi_decoder_t;


void decode (char* encoded, char *decoded, int decoded_len) {

    viterbi_decoder_t decoder;

    int acc = 0;

    int inbyte = 0;
    int inbit = 0;
    int ncodedbits = (decoded_len * CODING_RATE * 8);

    for (int state = 0; state != STATES; state += 1) {
        decoder.state[state].cost = state ? ncodedbits : 0;
    }

    int memcpycnt = 0;

    for (int byte = 0; byte != decoded_len; byte += 1) {
        for (int bit = 0; bit != 8; bit += 1) {
            int in = 0;
            for (int k = 0; k != CODING_RATE; k++) {
                in |= (encoded[inbyte] & 0x80) ? (1 << k) : 0;
                encoded[inbyte] <<= 1;
                inbit += 1;
                if (inbit == 8) {
                    inbit = 0;
                    inbyte += 1;
                }
            }

            for (int state = 0; state != STATES; state += 1) {
                decoder.state[state].newcost = ncodedbits;
            }

            for (int state = 0; state != STATES; state += 1) {

                for (int be = 0; be != 2; be++) {
                    int wrk_acc = state;
                    int out = encode_bit(be, &wrk_acc);
                    int newstate = wrk_acc & (STATES - 1);
                    int cost = decoder.state[state].cost + HAMMING_DIST(in, out);
                    if (cost <= decoder.state[newstate].cost) {
                        memcpy(decoder.state[newstate].data, decoder.state[state].data, DATA_LEN);
                        memcpycnt += 1;
                    }
                    if (cost <= decoder.state[newstate].newcost) {
                        decoder.state[newstate].data[byte] &= ~(1 << bit);
                        decoder.state[newstate].data[byte] |= be ? (1 << bit) : 0;

                        decoder.state[newstate].newcost = cost;
                    }
                }
            }
            for (int state = 0; state != STATES; state += 1) {
                decoder.state[state].cost = decoder.state[state].newcost;
            }

        }
    }

    int mincost = ncodedbits;
    int minpath = 0;
    memcpy(decoded,  decoder.state[minpath].data, decoded_len);
}


int main (int argc, char** argv) {

    char* message = strdup("Hello World, this is a fairly long message!");
    int len = strlen(message) + 1;
    int encoded_len = (len + 1) * CODING_RATE;
    char* encoded_msg = (char*)malloc(encoded_len);

    // Encoding and erasing the original message
    encode(message, encoded_msg, len);
    memset(message, 0x00, len);

    // Adding some bit errors
    biterrors(encoded_msg, len*2);

    // Decoding
    decode(encoded_msg, message, len);

    printf("%s\n", message);
    free(message);
    free(encoded_msg);
    return 0;
}



