#ifndef RUNTIME_H
#define RUNTIME_H

#include <stdint.h>

#define ZERO8 0, 0, 0, 0, 0, 0, 0, 0
#define INT8 int, int, int, int, int, int, int, int

typedef struct closure closure;

// Alloc space for GC, init initial state
void init_GC(void *base_sp);
void gc_collect();

// Print Garbage Collector stats.
void print_gc_stats();
// Print Garbage Collector stats and current space layout.
void print_gc_status();
// Get start address of current new space
void **get_heap_start();
// Get end address of current new space
void **get_heap_fin();

void *alloc_closure(INT8, void *f, uint8_t argc);
// Iteratively applies arguments to a closure (effectively, all at once if possible),
// supporting partial and over-application.
void *apply_closure_chain(INT8, closure *old_clos, uint8_t argc, ...);

#endif
