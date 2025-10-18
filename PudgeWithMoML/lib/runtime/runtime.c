#include <stdio.h>

extern void print_int(int n);

void print_int(int n) {
    printf("%d\n", n);
}

void flush() {
    fflush(stdout);
}
