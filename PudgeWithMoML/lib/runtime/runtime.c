#include <assert.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void *call_closure(void *code, uint64_t argc, void **argv);

void print_int(int n) { printf("%d\n", n); }

void flush() { fflush(stdout); }

// size in words
#define GC_SPACE_INITIAL_SIZE (1600)

// HEAP structure
// word: value
//
// 0:               [N_0 = size in words]
// 1:               [data]
// ...              [...data]
// N_0:             [data]
// N_0 + 1:         [N_2 = size in words]
// N_0 + 2:         [data]
// ...   ....       [..data]
// N_0 + (N_2 - 1): [data]

typedef struct {
  void *base_sp;
  size_t space_capacity; // dynamic size in words
  void **new_space;
  size_t alloc_offset; // first free word offset in new space
  void **old_space;
  size_t alloc_count;
  size_t collect_count;
} GC_state;

static GC_state gc;

typedef struct {
  void *code;
  size_t argc;
  size_t argc_recived;
  void *args[];
} closure;

#define ZERO8 0, 0, 0, 0, 0, 0, 0, 0
#define INT8 int, int, int, int, int, int, int, int

// Print stats about Garbage Collector work
void print_gc_status() {
  printf("=== GC status ===\n");
  printf("Base stack pointer: %x\n", gc.base_sp);
  printf("Current space capacity: %ld\n", gc.space_capacity);
  printf("Allocated words in new space: %ld\n", gc.alloc_offset);

  printf("Current new space:\n");
  size_t offset = 0;
  while (1) {
    size_t size = (size_t)gc.new_space[offset];
    printf("\t0x%x: [size: %ld]\n", offset, size);
    offset++;
    for (size_t i = 0; i < size; i++) {
      printf("\t0x%x: ", offset);
      printf("[data: 0x%x]\n", gc.new_space[offset]);
      offset++;
    }

    if (offset >= gc.alloc_offset) {
      break;
    }
  }

  printf("=== GC status ===\n");

  return;
}

// Alloc space for GC, init initial state
void init_GC(INT8, void *base_sp) {
  // I have problems with modify global variables in direct way
  gc.base_sp = base_sp;
  gc.space_capacity = GC_SPACE_INITIAL_SIZE;
  gc.new_space = malloc(sizeof(void *) * GC_SPACE_INITIAL_SIZE);
  gc.alloc_offset = 0;
  gc.old_space = malloc(sizeof(void *) * GC_SPACE_INITIAL_SIZE);

  return;
}

// if caller function wants to save some regs that my collect_riscv_state
// function may destroy (for ex. during creating regs[26]) then caller puts
// their values on stack. so we don't lose any address that points to object in
// heap
// TODO: riscv calling conventions
static void **collect_riscv_state() {
  // t0-t6 (7), a0-a7 (8), s1-s11 (11)
  size_t *regs = malloc(sizeof(size_t) * 26);

  asm volatile("sd t0, 0(%0)\n\t"
               "sd t1, 8(%0)\n\t"
               "sd t2, 16(%0)\n\t"
               "sd t3, 24(%0)\n\t"
               "sd t4, 32(%0)\n\t"
               "sd t5, 40(%0)\n\t"
               "sd t6, 48(%0)\n\t"
               "sd a0, 56(%0)\n\t"
               "sd a1, 64(%0)\n\t"
               "sd a2, 72(%0)\n\t"
               "sd a3, 80(%0)\n\t"
               "sd a4, 88(%0)\n\t"
               "sd a5, 96(%0)\n\t"
               "sd a6, 104(%0)\n\t"
               "sd a7, 112(%0)\n\t"
               "sd s1, 120(%0)\n\t"
               "sd s2, 128(%0)\n\t"
               "sd s3, 136(%0)\n\t"
               "sd s4, 144(%0)\n\t"
               "sd s5, 152(%0)\n\t"
               "sd s6, 160(%0)\n\t"
               "sd s7, 168(%0)\n\t"
               "sd s8, 176(%0)\n\t"
               "sd s9, 184(%0)\n\t"
               "sd s10, 192(%0)\n\t"
               "sd s11, 200(%0)\n\t"
               :
               : "r"(regs)
               : "memory");

  return (void **)regs;
}

// alloc size bytes in gc.memory
void *my_malloc(size_t size) {
  // printf("MY MALLOC: %ld\n", size);
  if (size == 0) {
    return NULL;
  }

  // 8 byte rounding
  if (size % 8 != 0) {
    size = size + (8 - (size % 8));
  }

  size_t words = size / 8;

  // no free space left after alloc size bytes + header
  if (gc.alloc_offset + (words + 1) >= gc.space_capacity) {
    // gc_collect();

    // after collecting we still don't have space
    if (gc.alloc_offset + (words + 1) >= gc.space_capacity) {
      size_t mult = 1;

      while (gc.alloc_offset + (words + 1) >= (gc.space_capacity * mult)) {
        mult *= 2;
      }

      gc.space_capacity *= mult;
      gc.new_space = realloc(gc.new_space, sizeof(void *) * gc.space_capacity);
      gc.old_space = realloc(gc.old_space, sizeof(void *) * gc.space_capacity);
    }
  }

  gc.new_space[gc.alloc_offset++] = (void *)words;
  void **result = gc.new_space + gc.alloc_offset;

  gc.alloc_offset += words;
  return result;
}

void *alloc_closure(INT8, void *f, uint8_t argc) {
  closure *clos = my_malloc(sizeof(closure) + sizeof(void *) * argc);

  clos->code = f;
  clos->argc = argc;
  clos->argc_recived = 0;
  memset(clos->args, 0, sizeof(void *) * argc);

  return clos;
}

void *copy_closure(closure *old_clos) {
  closure *clos = old_clos;
  closure *new = alloc_closure(ZERO8, clos->code, clos->argc);

  for (size_t i = 0; i < clos->argc_recived; i++) {
    new->args[new->argc_recived++] = clos->args[i];
  }

  return new;
}

#define WORD_SIZE (8)

// get closure and apply [argc] arguments to closure
void *apply_closure(INT8, closure *old_clos, uint8_t argc, ...) {
  closure *clos = copy_closure(old_clos);
  // printf("CLOS: 0x%x\n", clos);
  // print_gc_status();
  // fflush(stdout);
  va_list list;
  va_start(list, argc);

  if (clos->argc_recived + argc > clos->argc) {
    fprintf(stderr,
            "Runtime error: function accept more arguments than expect\n");
    exit(122);
  }

  for (size_t i = 0; i < argc; i++) {
    void *arg = va_arg(list, void *);
    clos->args[clos->argc_recived++] = arg;
  }
  va_end(list);

  // if application is partial
  if (clos->argc_recived < clos->argc) {
    return clos;
  }

  // full application (we need pass all arguments to stack and exec function)
  assert(clos->argc_recived == clos->argc);

  return call_closure(clos->code, clos->argc, clos->args);
}
