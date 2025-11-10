#include <assert.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if false
#define LOG(fmt, ...) printf(fmt, ##__VA_ARGS__)
#define LOGF(fun) fun
#else
#define LOG(fmt, ...) ((void)0)
#define LOGF(fun) ((void)0)
#endif

// each run of tests change, for example, initial sp address or address of heap
// so when we want stable ci tests -- we mock that value
#define STABLE_CI true

extern void *call_closure(void *code, uint64_t argc, void **argv);

void print_int(size_t n) { printf("%d\n", n); }

void flush() { fflush(stdout); }

// size in words
#define GC_SPACE_INITIAL_SIZE (8192)
#define WORD_SIZE (8)

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
  size_t allocated_bytes_count;
  size_t collect_count;
} GC_state;

static GC_state gc;
void *first_new_space; // for stable CI

typedef struct {
  void *code;
  size_t argc;
  size_t argc_recived;
  void *args[];
} closure;

#define ZERO8 0, 0, 0, 0, 0, 0, 0, 0
#define INT8 int, int, int, int, int, int, int, int

void print_stack(void *current_sp);

// Print stats about Garbage Collector work
void print_gc_status() {
  printf("=== GC status ===\n");
  // printf("Base stack pointer: %x\n", STABLE_CI ? (void *)0x122 : gc.base_sp);
  printf("Start address of new space: %x\n",
         STABLE_CI ? (gc.new_space == first_new_space
                          ? (void *)0x1000
                          : (void *)(0x1000 + GC_SPACE_INITIAL_SIZE * 8))
                   : gc.new_space);
  printf("Allocate count: %ld times\n", gc.alloc_count);
  printf("Collect count: %ld times\n", gc.collect_count);
  printf("Current space capacity: %ld words\n", gc.space_capacity);
  printf("Total allocated memory: %ld words\n",
         gc.allocated_bytes_count / WORD_SIZE);
  printf("Allocated words in new space: %ld words\n", gc.alloc_offset);

  printf("Current new space:\n");
  size_t offset = 0;
  while (offset < gc.alloc_offset) {
    size_t size = (size_t)gc.new_space[offset];

    void **addr = gc.new_space + offset;
    if (STABLE_CI) {
      if (gc.new_space == first_new_space) {
        addr = ((void **)0x1000) + offset;
      } else {
        addr = ((void **)0x1000) + GC_SPACE_INITIAL_SIZE + offset;
      }
    }

    printf("\t(0x%x) 0x%x: [size: %ld]\n", addr, offset, size);
    offset++;

    for (size_t i = 0; i < size; i++) {
      printf("\t(0x%x) 0x%x: ", addr + i + 1, offset);
      printf("[data: 0x%x]\n", gc.new_space[offset]);
      offset++;
    }
  }

  printf("=== GC status ===\n");

  void *current_sp = NULL;
  asm volatile("mv %0, sp" : "=r"(current_sp));
  LOGF(print_stack(current_sp));

  return;
}

// Alloc space for GC, init initial state
void init_GC(void *base_sp) {
  // I have problems with modify global variables in direct way
  gc.base_sp = base_sp;
  gc.space_capacity = GC_SPACE_INITIAL_SIZE;
  gc.new_space = malloc(sizeof(void *) * GC_SPACE_INITIAL_SIZE);
  first_new_space = gc.new_space;
  gc.alloc_offset = 0;
  gc.old_space = malloc(sizeof(void *) * GC_SPACE_INITIAL_SIZE);

  return;
}

// clear all registers
void clear_regs() {
  // t0-t6 (7), a0-a7 (8), s1-s11 (11)

  asm volatile("li t0, 0\n\t"
               "li t1, 0\n\t"
               "li t2, 0\n\t"
               "li t3, 0\n\t"
               "li t4, 0\n\t"
               "li t5, 0\n\t"
               "li t6, 0\n\t"
               "li a0, 0\n\t"
               "li a1, 0\n\t"
               "li a2, 0\n\t"
               "li a3, 0\n\t"
               "li a4, 0\n\t"
               "li a5, 0\n\t"
               "li a6, 0\n\t"
               "li a7, 0\n\t"
               "li s1, 0\n\t"
               "li s2, 0\n\t"
               "li s3, 0\n\t"
               "li s4, 0\n\t"
               "li s5, 0\n\t"
               "li s6, 0\n\t"
               "li s7, 0\n\t"
               "li s8, 0\n\t"
               "li s9, 0\n\t"
               "li s10, 0\n\t"
               "li s11, 0\n\t");

  return;
}

// if caller function wants to save some regs that my collect_riscv_state
// function may destroy (for ex. during creating regs[26]) then caller puts
// their values on stack. so we don't lose any address that points to object
// in heap
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

static void set_riscv_reg(int idx, void *val) {
  switch (idx) {
  case 0:
    asm volatile("mv t0, %0" ::"r"(val));
    break;
  case 1:
    asm volatile("mv t1, %0" ::"r"(val));
    break;
  case 2:
    asm volatile("mv t2, %0" ::"r"(val));
    break;
  case 3:
    asm volatile("mv t3, %0" ::"r"(val));
    break;
  case 4:
    asm volatile("mv t4, %0" ::"r"(val));
    break;
  case 5:
    asm volatile("mv t5, %0" ::"r"(val));
    break;
  case 6:
    asm volatile("mv t6, %0" ::"r"(val));
    break;
  case 7:
    asm volatile("mv a0, %0" ::"r"(val));
    break;
  case 8:
    asm volatile("mv a1, %0" ::"r"(val));
    break;
  case 9:
    asm volatile("mv a2, %0" ::"r"(val));
    break;
  case 10:
    asm volatile("mv a3, %0" ::"r"(val));
    break;
  case 11:
    asm volatile("mv a4, %0" ::"r"(val));
    break;
  case 12:
    asm volatile("mv a5, %0" ::"r"(val));
    break;
  case 13:
    asm volatile("mv a6, %0" ::"r"(val));
    break;
  case 14:
    asm volatile("mv a7, %0" ::"r"(val));
    break;
  case 15:
    asm volatile("mv s1, %0" ::"r"(val));
    break;
  case 16:
    asm volatile("mv s2, %0" ::"r"(val));
    break;
  case 17:
    asm volatile("mv s3, %0" ::"r"(val));
    break;
  case 18:
    asm volatile("mv s4, %0" ::"r"(val));
    break;
  case 19:
    asm volatile("mv s5, %0" ::"r"(val));
    break;
  case 20:
    asm volatile("mv s6, %0" ::"r"(val));
    break;
  case 21:
    asm volatile("mv s7, %0" ::"r"(val));
    break;
  case 22:
    asm volatile("mv s8, %0" ::"r"(val));
    break;
  case 23:
    asm volatile("mv s9, %0" ::"r"(val));
    break;
  case 24:
    asm volatile("mv s10, %0" ::"r"(val));
    break;
  case 25:
    asm volatile("mv s11, %0" ::"r"(val));
    break;
  default:
    break;
  }
}

void print_stack(void *current_sp) {
  printf("=== STACK status ===\n");
  printf("BASE_SP: 0x%x, CURRENT_SP: 0x%x\n", gc.base_sp, current_sp);
  size_t stack_size = (gc.base_sp - current_sp) / 8;
  printf("STACK SIZE: %ld\n", stack_size);

  for (size_t i = 0; i < stack_size; i++) {
    uint64_t *byte = (uint64_t *)gc.base_sp - i;
    printf("\t0x%x: 0x%x\n", byte, *byte);
  }

  printf("=== STACK status ===\n");

  return;
}

// When we exec gc_collect we have on a heap objects:
// [size 3] [data 0] [data 1] [data 2] [size 1] [data 0] [size 2] ...
// We iterate through heap and try to find poiters to "data 0" on stack\regs
// If we find it in first time:
//   1) move size bytes to the old_space
//   2) save new pointer to old_space
//   3) iterate through stack\regs and replace all pointer to the new
//   pointer
void _gc_collect(void *current_sp) {
  if (gc.alloc_offset == 0) {
    return;
  }

  void **regs = collect_riscv_state();
  LOGF(print_stack(current_sp));

  size_t stack_size = (gc.base_sp - current_sp) / 8;
  size_t cur_offset = 0;
  size_t old_space_offset = 0;
  while (cur_offset < gc.alloc_offset) {
    void *new_pointer = NULL;
    size_t cur_size = (size_t)gc.new_space[cur_offset];
    void *cur_pointer = gc.new_space + cur_offset + 1;

    if (cur_size == 0) {
      fprintf(
          stderr,
          "You have object on heap with zero size\nBug in malloc function!\n");
      print_gc_status();
      exit(122);
    }

    LOG("Try to find stack cell with 0x%x value on 0x%ld offset\n", cur_pointer,
        cur_offset + 1);

    // try to find in regs and stack at least one pointer
    {
      bool found = false;

      // regs
      for (size_t i = 0; i < 26; i++) {
        if (regs[i] == cur_pointer) {
          LOG("FOUND AT REG: %ld\n", i);
          found = true;
          break;
        }
      }

      // stack
      for (size_t i = 0; i < stack_size; i++) {
        void **byte = (void **)gc.base_sp - i - 1;
        if (*byte == cur_pointer) {
          LOG("FOUND AT STACK: %ld. CUR_OFFSET: %x, CUR_POINTER: %x, byte: "
              "%x, *byte: %x\n",
              i, cur_offset, cur_pointer, byte, *byte);
          found = true;
          break;
        }
      }

      if (!found) {
        cur_offset += cur_size + 1;
        continue;
      }

      // copy to old space
      gc.old_space[old_space_offset++] = (void *)cur_size;
      new_pointer = gc.old_space + old_space_offset;
      for (size_t j = 0; j < cur_size; j++) {
        gc.old_space[old_space_offset++] = gc.new_space[cur_offset + 1 + j];
      }
      LOG("NEW POINTER: 0x%x\n", new_pointer);
    }

    LOG("RUN CHANGING\n");
    // change all occurences
    {
      // regs
      for (size_t i = 0; i < 26; i++) {
        if (regs[i] == cur_pointer) {
          set_riscv_reg(i, new_pointer);
        }
      }

      // stack
      for (size_t i = 0; i < stack_size; i++) {
        void **byte = (void **)gc.base_sp - i - 1;
        if (*byte == cur_pointer) {
          LOG("Change stack cell 0x%x. 0x%x -> 0x%x\n", byte, *byte,
              new_pointer);
          *byte = new_pointer;
        }
      }
    }

    cur_offset += cur_size + 1;
  }
  LOGF(print_stack(current_sp));

  void *temp = gc.new_space;
  gc.new_space = gc.old_space;
  gc.old_space = temp;
  gc.alloc_offset = old_space_offset;

  gc.collect_count++;
}

// WARNING: if you read stack pointer in _gc_collect function than when you go
// through stack you can change local variables of _gc_collect fuction
// So we write wrapper only for reading stack pointer **before** _gc_collect
// function It took 4 hours for debug this chaos 🐣🐣🐤🐤🐔🐔🦆🦆🐹🐹🐹🐹
void gc_collect() {
  void *current_sp = NULL;
  asm volatile("mv %0, sp" : "=r"(current_sp));
  _gc_collect(current_sp);
}

// alloc size bytes in gc.memory
void *my_malloc(size_t size) {
  LOG("MY MALLOC: %ld\n", size);
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
    LOG("no free space\n");
    gc_collect();

    // after collecting we still don't have space
    if (gc.alloc_offset + (words + 1) >= gc.space_capacity) {
      fprintf(stderr, "panic! overflow memory limits\n");
      fflush(stderr);
      exit(122);
    }
  }

  gc.new_space[gc.alloc_offset++] = (void *)words;
  void **result = gc.new_space + gc.alloc_offset;

  gc.alloc_offset += words;
  gc.alloc_count++;
  gc.allocated_bytes_count += size + WORD_SIZE;
  return result;
}

// get heap start of current new_space
void **get_heap_start() {
  if (!STABLE_CI) {
    return gc.new_space;
  }

  return gc.new_space == first_new_space
             ? (void **)0x1000
             : ((void **)0x1000) + GC_SPACE_INITIAL_SIZE;
}

// get heap end of current new_space
void **get_heap_fin() {
  if (!STABLE_CI) {
    return gc.new_space + gc.space_capacity;
  }

  return (gc.new_space == first_new_space
              ? (void **)0x1000
              : ((void **)0x1000) + GC_SPACE_INITIAL_SIZE) +
         gc.space_capacity;
}

void *alloc_closure(INT8, void *f, uint8_t argc) {
  LOG("alloc_closure(0x%x, %d)\n", f, argc);
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

  LOG("old clos: 0x%x, new clos: 0x%x\n", clos, new);
  LOG("clos.code: 0x%x, clos argc: 0x%d\n", clos->code, clos->argc);

  for (size_t i = 0; i < clos->argc_recived; i++) {
    new->args[new->argc_recived++] = clos->args[i];
  }

  return new;
}

// get closure and apply [argc] arguments to closure
void *apply_closure(INT8, closure *old_clos, uint8_t argc, ...) {
  closure *clos = copy_closure(old_clos);
  LOG("CLOS: 0x%x\n", clos);
  LOGF(print_gc_status());
  fflush(stdout);
  va_list list;
  va_start(list, argc);

  if (clos->argc_recived + argc > clos->argc) {
    fprintf(stdout,
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
