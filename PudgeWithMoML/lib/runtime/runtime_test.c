#include <assert.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void *call_closure(void *code, uint64_t argc, void **argv);

void print_int(size_t n) { printf("%d\n", n); }

void flush() { fflush(stdout); }

// size in words
#define GC_SPACE_INITIAL_SIZE (160)

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

// mocked stack and regs
void **my_stack;
void **regs;
void *current_sp;

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
  printf("Start address of new space: %x\n", gc.new_space);
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

void print_stack() {
  printf("=== STACK status ===\n");
  size_t stack_size = (gc.base_sp - current_sp) / 8;
  printf("STACK SIZE: %ld\n", stack_size);

  for (size_t i = 0; i < stack_size; i++) {
    uint64_t *byte = (uint64_t *)gc.base_sp - i;
    printf("\t0x%x: 0x%x\n", byte, *byte);
  }

  printf("=== STACK status ===\n");

  return;
}

// Alloc space for GC, init initial state
void init_GC(void *base_sp) {
  // I have problems with modify global variables in direct way
  gc.base_sp = base_sp;
  gc.space_capacity = GC_SPACE_INITIAL_SIZE;
  gc.new_space = malloc(sizeof(void *) * GC_SPACE_INITIAL_SIZE);
  gc.alloc_offset = 0;
  gc.old_space = malloc(sizeof(void *) * GC_SPACE_INITIAL_SIZE);

  return;
}

static void **collect_riscv_state() {
  void **_regs = malloc(sizeof(void *) * 26);

  regs = _regs;

  return _regs;
}

static void set_riscv_reg(int idx, void *val) { regs[idx] = val; }

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

    LOGF(print_stack());
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
        void **byte = (void **)gc.base_sp - i;
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
      new_pointer = gc.old_space + old_space_offset;
      gc.old_space[old_space_offset++] = (void *)cur_size;
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
        void **byte = (void **)gc.base_sp - i;
        if (*byte == cur_pointer) {
          LOG("Change stack cell 0x%x. 0x%x -> 0x%x\n", byte, *byte,
              new_pointer);
          *byte = new_pointer;
        }
      }
    }
    LOGF(print_stack());

    cur_offset += cur_size + 1;
  }

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
  printf("MY MALLOC: %ld\n", size);
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
    printf("no free space\n");
    gc_collect();

    // after collecting we still don't have space
    if (gc.alloc_offset + (words + 1) >= gc.space_capacity) {
      fprintf(stderr, "panic! overflow memory limits\n");
      fflush(stderr);
      exit(122);
      size_t mult = 1;

      while (gc.alloc_offset + (words + 1) >= (gc.space_capacity * mult)) {
        mult *= 2;
      }

      gc.space_capacity *= mult;
      gc.new_space = realloc(gc.new_space, sizeof(void *) * gc.space_capacity);
      gc.old_space = realloc(gc.old_space, sizeof(void *) * gc.space_capacity);
    }
  }

  printf("words: %ld\n", words);
  gc.new_space[gc.alloc_offset++] = (void *)words;
  void **result = gc.new_space + gc.alloc_offset;

  gc.alloc_offset += words;
  return result;
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

  printf("old clos: 0x%x, new clos: 0x%x\n", clos, new);
  printf("clos.code: 0x%x, clos argc: 0x%d\n", clos->code, clos->argc);

  for (size_t i = 0; i < clos->argc_recived; i++) {
    new->args[new->argc_recived++] = clos->args[i];
  }

  return new;
}

#define WORD_SIZE (8)

int main(int argc, char **argv) {
  my_stack = (void **)malloc(sizeof(void *) * 32);
  init_GC(my_stack + 32);
  current_sp = my_stack + 32 - 8;
  regs = malloc(sizeof(void *) * 26);

  if (0) {
    print_gc_status();
    alloc_closure(ZERO8, (void *)0xFF, 2);
    alloc_closure(ZERO8, (void *)0xFFF, 3);
    alloc_closure(ZERO8, (void *)0xFFFF, 4);
    print_gc_status();
    gc_collect();
    // must be empty
    print_gc_status();
  }

  if (0) {
    print_gc_status();
    void *clos = alloc_closure(ZERO8, (void *)0xFF, 2);
    alloc_closure(ZERO8, (void *)0xFFF, 3);
    alloc_closure(ZERO8, (void *)0xFFFF, 4);
    print_gc_status();
    regs[12] = clos;
    gc_collect();
    // must has first closure
    print_gc_status();
  }

  if (0) {
    print_gc_status();
    alloc_closure(ZERO8, (void *)0xFF, 2);
    alloc_closure(ZERO8, (void *)0xFFF, 3);
    void *clos = alloc_closure(ZERO8, (void *)0xFFFF, 4);
    print_gc_status();
    regs[12] = clos;
    gc_collect();
    // must has third closure
    print_gc_status();
  }

  if (0) {
    print_gc_status();
    void *clos1 = alloc_closure(ZERO8, (void *)0xFF, 2);
    alloc_closure(ZERO8, (void *)0xFFF, 3);
    void *clos2 = alloc_closure(ZERO8, (void *)0xFFFF, 4);
    print_gc_status();
    regs[12] = clos1;
    my_stack[32 - 2] = clos2;
    print_stack();
    gc_collect();
    // must has first and third closure
    print_gc_status();
  }

  if (1) {
    print_gc_status();
    void *clos1 = alloc_closure(ZERO8, (void *)0xFF, 2);
    print_gc_status();
    regs[12] = clos1;
    print_stack();
    gc_collect();
    print_gc_status();
  }

  printf("Done\n");
  return 0;
}