#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

typedef struct node_s {
    char byte;
    int occurrence;
    struct node_s   *zero;
    struct node_s   *one;
    struct node_s   *next;
} node_t;

static node_t *head;

/*
 * Simple greedy bubble sort
 */
void
sort (void) {
    node_t **i;
    int change;

    if ((!head) || (!head->next)) {
        return;
    }

    do {
        change = 0;
        for (i = &head; (*i)->next; i = &((*i)->next)) {

            if ((*i)->next->occurrence < (*i)->occurrence) {

                node_t *cur = (*i);
                node_t *nxt = (*i)->next->next;

                (*i) = (*i)->next;
                (*i)->next = cur;
                (*i)->next->next = nxt;

                change = 1;
                break;
            }
        }
    } while (change);
}


/*
 * DFS, printing out the codes
 */
static char codestr[32];

void
dfs (node_t *n, int d, char str[]) {

    if (!n->zero) {
        str[d++] = ' ';
        str[d++] = '[';
        str[d++] = n->byte;
        str[d++] = ']';
        str[d++] = '\0';
        printf("%s\n", str);
    } else {

        if (n->zero) {
            str[d] = '0';
            dfs(n->zero, d+1, str);
        }
        if (n->one) {
            str[d] = '1';
            dfs(n->one, d+1, str);
        }
    }
}

int
main (int argc, char** argv) {
    int fi;
    size_t bytes = 1;
    char byte;
    node_t *i;

    head = NULL;

    fi = open("./text.txt", O_RDONLY);

    while (bytes) {
        int newsymbol = 1;
        bytes = read(fi, &byte, 1);
        printf("%c", byte);

        for (i = head; i; i = i->next) {
            if (i->byte == byte) {
                newsymbol = 0;
                i->occurrence++;
            }
        }
        if (newsymbol) {
            node_t* newnode = malloc(sizeof(node_t));
            memset(newnode, 0x00, sizeof(node_t));
            newnode->byte = byte;
            newnode->occurrence = 1;
            newnode->next = head;
            head = newnode;
        }
    }
    close(fi);

    sort();
    for (i = head; i; i = i->next) {
        printf("[%c]  (%i) \n", i->byte, i->occurrence);
    }


    /*
     * Collapsing the list by building binary tree of the two least frequent nodes
    */
    while (head && head->next) {
        sort();
        node_t* newnode = malloc(sizeof(node_t));
        memset(newnode, 0x00, sizeof(node_t));
        newnode->byte = '@';
        newnode->occurrence = head->occurrence + head->next->occurrence;
        newnode->next = head->next->next;
        newnode->zero = head;
        newnode->one = head->next;
        head = newnode;
    }

    dfs(head, 0, codestr);

    return 0;
}

