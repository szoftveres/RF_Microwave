#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct code_s {
    int     bits;
    int     *d;
    int     max1;
    int     max2;
    int     balance;
    struct code_s *next;
} code_t;


int analyze_code (code_t *code) {
    int *pad_fixed = (int*)malloc(sizeof(int) * code->bits * 3);
    int *pad_moving = (int*)malloc(sizeof(int) * code->bits * 3);

    memset(pad_fixed, 0x00, sizeof(int) * code->bits * 3);
    memset(pad_moving, 0x00, sizeof(int) * code->bits * 3);
    memcpy(&(pad_fixed[code->bits]), code->d, sizeof(int) * code->bits);
    memcpy(pad_moving, code->d, sizeof(int) * code->bits);

    code->max1 = 0;
    code->max2 = 0;

    for (int i = 0; i <= (code->bits * 2); i++) {
        int sum = 0;
        for (int c = 0; c != (code->bits * 3); c++) {
            sum += (pad_fixed[c] * pad_moving[c]);
        }
        if (sum > code->max1) {
            code->max2 = code->max1;
            code->max1 = sum;
        } else if (sum > code->max2) {
            code->max2 = sum;
        }
        memmove(&(pad_moving[1]), pad_moving, sizeof(int) * ((code->bits * 3) - 1));
        pad_moving[0] = 0;
    }

    free(pad_moving);
    free(pad_fixed);

    if (code->max2 > 1) {
        code->max1 = 0;
        code->max2 = 0;
    }

    return (code->max1 - code->max2);
}


void init_zero_code (code_t *code) {
    for (int i = 0; i != code->bits; i++) {
        code->d[i] = -1;
    }
    code->balance = -(code->bits);
}


void push_code_stack (code_t **head, code_t *code) {
    code_t *new = (code_t*)malloc(sizeof(code_t));
    memcpy(new, code, sizeof(code_t));
    new->d = (int*)malloc(sizeof(int) * new->bits);
    memcpy(new->d, code->d, sizeof(int) * new->bits);
    new->next = *head;
    *head = new;
}


void empty_code_stack (code_t **head) {
    code_t *current;
    while (*head) {
        current = *head;
        free(current->d);
        *head = current->next;
        free(current);
    }
}


int increment_code (code_t *code) {
    int carry = 1;
    for (int i = 0; i != code->bits; i++) {
        if (carry) {
            if (code->d[i] == -1) {
                code->d[i] = 1;
                code->balance += 2;
                carry = 0;
            } else if (code->d[i] == 1) {
                code->d[i] = -1;
                code->balance -= 2;
                carry = 1;
            }
        }
    }
    return carry;
}


void print_code (code_t *code) {
    for (int i = 0; i != code->bits; i++) {
        switch (code->d[i]) {
            case -1:
                printf("0"); break;
            case 1:
                printf("1"); break;
            default:
                printf("-- invalid --"); break;
        }
    }
}


int main (int argc, char **argv) {
    code_t code;
    code_t *head = NULL;

    for (int bits = 8; bits != 33; bits++) {
        memset(&code, 0x00, sizeof(code_t));

        code.d = (int*)malloc(sizeof(int) * bits);
        code.bits = bits;

        int max = 1;
        int carry = 0;

        init_zero_code(&code);

        while (!carry) {
            if ((code.balance <= 2) && (code.balance >= -2)) {
                int diff = analyze_code(&code);

                if (diff > max) {
                    max = diff;
                    empty_code_stack(&head);
                }
                if (diff == max) {
                    push_code_stack(&head, &code);
                }
            }
            carry = increment_code(&code);
        }

        for (code_t *i = head; i; i = i->next) {
            print_code(i);
            int diff = analyze_code(i);
            printf("  bits: %i, d:%i\n", bits, diff);
        }
        empty_code_stack(&head);

        printf("bits: %i, Max : %i\n", bits, max);
        free(code.d);
    }
    return 0;
}


