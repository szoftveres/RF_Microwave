#ifndef __DCT_H__
#define __DCT_H__

int dct (double src[], double dst[], size_t len);

double get_point (double src[], size_t len, double point);

int idct (double src[], double dst[], size_t len);


#endif
