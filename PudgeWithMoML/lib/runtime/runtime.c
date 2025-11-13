#include <assert.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if false
#define LOG(fmt, ...)                                                                                                  \
  {                                                                                                                    \
    printf(fmt, ##__VA_ARGS__);                                                                                        \
    fflush(stdout);                                                                                                    \
  }
#define LOGF(fun) fun
#else
#define LOG(fmt, ...) ((void)0)
#define LOGF(fun) ((void)0)
#endif

extern void *call_closure(void *code, uint64_t argc, void **argv);
extern void *__start_gcroots __attribute__((weak));
extern void *__stop_gcroots __attribute__((weak));

void print_int(size_t n) {
  n >>= 1;
  printf("%d\n", n);
}

void flush() { fflush(stdout); }

// New and old space size in words.
#define SPACE_MINIMUM_SIZE (8192)
#define WORD_SIZE 8

// All adresses are printed relative to the new_space with GC_HEAP_OFFSET.
// For example, space size is 0x1000, gc.heap_start = 0x10000, old_space = 0x10000, new_space = 0x11000, GC_HEAP_OFFSET
// = 0x100000, then if some data have address 0x11256, then we print it as gc.new_space - gc.heap_start + 0x11256 +
// GC_HEAP_OFFSET = 0x100256
#define GC_HEAP_OFFSET (0x100000000)

// HEAP structure
// word number      value
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
  size_t space_capacity; // current space size in words
  void **heap_start;     // start address of spaces (spaces are arranged in a row)
  void **new_space;
  size_t alloc_offset; // first free word offset in new space
  void **old_space;
  size_t alloc_count;       // total number of allocations
  size_t alloc_bytes_count; // total number of allocated bytes
  size_t collect_count;
  size_t obj_count; // number of live objects in new space
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

static void print_stack(void *current_sp);

// Print stats about Garbage Collector work
void print_gc_status() {
  printf("=== GC status ===\n");
  printf("Start address of new space: %x\n", gc.new_space - gc.heap_start + (void **)GC_HEAP_OFFSET);
  printf("Allocate count: %ld times\n", gc.alloc_count);
  printf("Collect count: %ld times\n", gc.collect_count);
  printf("Current space capacity: %ld words\n", gc.space_capacity);
  printf("Total allocated memory: %ld words\n", gc.alloc_bytes_count / WORD_SIZE);
  printf("Allocated words in new space: %ld words\n", gc.alloc_offset);
  printf("Live objects in new space: %ld\n", gc.obj_count);

  printf("Current new space:\n");
  size_t offset = 0;
  while (offset < gc.alloc_offset) {
    size_t size = (size_t)gc.new_space[offset];

    void **addr = gc.new_space + offset;
    if (gc.new_space == gc.heap_start) {
      addr = ((void **)GC_HEAP_OFFSET) + offset;
    } else {
      addr = ((void **)GC_HEAP_OFFSET) + SPACE_MINIMUM_SIZE + offset;
    }

    printf("\t(0x%x) 0x%x: [size: %ld]\n", addr, offset, size);
    offset++;

    for (size_t i = 0; i < size; i++) {
      printf("\t(0x%x) 0x%x: ", addr + i + 1, offset);
      printf("[data: 0x%x]\n", gc.new_space[offset]);
      offset++;
    }
  }

  printf("=== GC status ===\n\n");

  void *current_sp = NULL;
  asm volatile("mv %0, sp" : "=r"(current_sp));
  LOGF(print_stack(current_sp));

  return;
}

// Alloc space for GC, init initial state
void init_GC(void *base_sp) {
  gc.base_sp = base_sp;
  gc.space_capacity = SPACE_MINIMUM_SIZE;
  void **heap = malloc(sizeof(void *) * SPACE_MINIMUM_SIZE * 2);
  gc.new_space = heap;
  gc.heap_start = heap;
  gc.alloc_offset = 0;
  gc.old_space = heap + SPACE_MINIMUM_SIZE;

  return;
}

static void print_stack(void *current_sp) {
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

// Change all pointers from old to new in .data section and at given stack (from current_sp to gc.base_sp)
static void update_stack_data_ptrs(void *current_sp, void *old, void *new) {
  size_t stack_size = (gc.base_sp - current_sp) / 8;

  // stack
  for (size_t i = 0; i < stack_size; i++) {
    void **byte = (void **)gc.base_sp - i - 1;
    if (*byte == old) {
      *byte = new;
    }
  }

  for (void **p = &__start_gcroots; p < &__stop_gcroots; ++p) {
    void **slot = (void **)*p;
    if (*slot == old)
      *slot = new;
  }

  return;
}

// Update all pointers in new_space, assuming they was copied from old_space
static void update_ptrs(void *current_sp, void **old_space, void **new_space, size_t size) {
  size_t cur_offset = 0;
  while (cur_offset < size) {
    size_t cur_size = (size_t)new_space[cur_offset];
    void *old_pointer = old_space + cur_offset + 1;
    void *new_pointer = new_space + cur_offset + 1;
    update_stack_data_ptrs(current_sp, old_pointer, new_pointer);

    for (size_t j = 0; j < cur_size; j++) {
      void **data_pointer = new_space + cur_offset + 1 + j;
      if ((uintptr_t)(*data_pointer) & 1) { // not a pointer
        continue;
      }

      if (*data_pointer < (void *)old_space || *data_pointer >= (void *)(old_space + size)) { // not a heap pointer
        continue;
      }

      // update data pointers so they point to a similar place in new_space
      size_t data_ptr_offset = (void **)*data_pointer - old_space;
      void *new_data_pointer = new_space + data_ptr_offset;
      new_space[cur_offset + 1 + j] = new_data_pointer;

      update_stack_data_ptrs(current_sp, *data_pointer, new_data_pointer);
    }

    cur_offset += cur_size + 1;
  }
}

// When we exec gc_collect we have on a heap objects:
// [size 3] [data 0] [data 1] [data 2] [size 1] [data 0] [size 2] ...
// We iterate through heap and try to find poiters to "data 0" on stack
// If we find it in first time:
//   1) move size bytes to the old_space
//   2) save new pointer to old_space
//   3) iterate through stack and replace all pointers to the new pointers
static void _gc_collect(void *current_sp) {
  if (gc.alloc_offset == 0) {
    return;
  }
  gc.obj_count = 0;

  LOGF(print_stack(current_sp));

  size_t stack_size = (gc.base_sp - current_sp) / 8;
  size_t cur_offset = 0;
  size_t old_space_offset = 0;
  while (cur_offset < gc.alloc_offset) {
    void *new_pointer = NULL;
    size_t cur_size = (size_t)gc.new_space[cur_offset];
    void **cur_pointer = gc.new_space + cur_offset + 1;

    if (cur_size == 0) {
      fprintf(stderr, "You have object on heap with zero size\nBug in malloc function!\n");
      print_gc_status();
      exit(122);
    }

    LOG("Try to find stack cell with 0x%x value on 0x%ld offset\n", cur_pointer, cur_offset + 1);

    // try to find in stack at least one pointer
    {
      bool found = false;

      // .data section
      for (void **p = &__start_gcroots; p < &__stop_gcroots; ++p) {
        void **slot = (void **)*p;
        if (*slot == cur_pointer) {
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

      // copy data to old space
      gc.old_space[old_space_offset++] = (void *)cur_size;
      new_pointer = gc.old_space + old_space_offset;
      for (size_t j = 0; j < cur_size; j++) {
        gc.old_space[old_space_offset++] = gc.new_space[cur_offset + 1 + j];
      }
      gc.obj_count++;
      LOG("NEW POINTER: 0x%x\n", new_pointer);
    }

    LOG("RUN CHANGING\n");
    // change all stack occurences
    update_stack_data_ptrs(current_sp, cur_pointer, new_pointer);
    // size is -1, first data is new pointer, this is how we mark that object is moved
    gc.new_space[cur_offset] = (void *)-1;
    *cur_pointer = new_pointer;

    cur_offset += cur_size + 1;
  }

  // check reference data
  cur_offset = 0;
  while (cur_offset < old_space_offset) {
    LOG("Start checking reference data");
    size_t cur_size = (size_t)gc.old_space[cur_offset++];
    for (size_t j = 0; j < cur_size; j++) {
      size_t data_offset = cur_offset++;
      void **data_pointer = gc.old_space[data_offset];
      if ((uintptr_t)data_pointer & 1) { // not a pointer
        continue;
      }

      if (data_pointer < gc.new_space || data_pointer >= gc.new_space + gc.alloc_offset) {
        continue;
      }

      size_t pointed_obj_size = (size_t)*(data_pointer - 1);
      if (pointed_obj_size == (size_t)-1) { // object is moved, update pointer
        void *new_pointer = *data_pointer;
        gc.old_space[data_offset] = new_pointer;
        continue;
      }

      // it is needed but not copied, so we copy pointed object to old space and update pointer
      gc.old_space[old_space_offset++] = (void *)pointed_obj_size;
      void *new_pointer = gc.old_space + old_space_offset;
      gc.old_space[data_offset] = new_pointer; // update current pointer
      for (size_t k = 0; k < pointed_obj_size; k++) {
        gc.old_space[old_space_offset++] = data_pointer[k];
      }

      gc.obj_count++;
      // mark as moved
      *(data_pointer - 1) = (void *)-1;
      *data_pointer = new_pointer;
    }
  }

  LOGF(print_stack(current_sp));

  void *temp = gc.new_space;
  gc.new_space = gc.old_space;
  gc.old_space = temp;
  gc.alloc_offset = old_space_offset;

  gc.collect_count++;
}

inline static void *get_sp() {
  void *current_sp = NULL;
  asm volatile("mv %0, sp" : "=r"(current_sp));
  return current_sp;
}

// WARNING: if you read stack pointer in _gc_collect function then when you go
// through stack you can change local variables of _gc_collect fuction
// So we write wrapper only for reading stack pointer **before** _gc_collect
// function It took 4 hours for debug this chaos 🐣🐣🐤🐤🐔🐔🦆🦆🐹🐹🐹🐹
void gc_collect() { _gc_collect(get_sp()); }

// alloc size bytes in gc.memory
static void *my_malloc(size_t size) {
  LOG("[DEBUG] %s(size: %ld)\n", __func__, size);
  if (size == 0) {
    return NULL;
  }

  void *current_sp = get_sp();

  // 8 byte rounding
  if (size % 8 != 0) {
    size = size + (8 - (size % 8));
  }

  size_t words = size / 8;

  // no free space left after alloc size bytes + header
  if (gc.alloc_offset + (words + 1) >= gc.space_capacity) {
    LOG("no free space\n");
    _gc_collect(current_sp);

    // after collecting we still don't have space
    if (gc.alloc_offset + (words + 1) >= gc.space_capacity) {
      LOG("Allocate more space for GC heap\n");

      void **old_heap = gc.heap_start;
      gc.space_capacity *= 2;
      void **new_heap = malloc(sizeof(void *) * gc.space_capacity * 2);
      memcpy(new_heap, gc.new_space, sizeof(void *) * gc.alloc_offset);
      update_ptrs(current_sp, gc.new_space, new_heap, gc.alloc_offset);
      free(old_heap);

      gc.heap_start = new_heap;
      gc.new_space = new_heap;
      gc.old_space = new_heap + gc.space_capacity;
    }
  }
  gc.obj_count++;

  gc.new_space[gc.alloc_offset++] = (void *)words;
  void **result = gc.new_space + gc.alloc_offset;

  gc.alloc_offset += words;
  gc.alloc_count++;
  gc.alloc_bytes_count += size + WORD_SIZE;

  LOG(" -> 0x%x\n", result);
  return result;
}

// Get start address of current new_space
void **get_heap_start() {
  LOG("[DEBUG] %s()\n", __func__);

  void **addr = gc.new_space - gc.heap_start + (void **)GC_HEAP_OFFSET;

  void **result = (void **)((((uintptr_t)addr) << 1) + 1);
  LOG(" -> 0x%x\n", result);
  return result;
}

// Get end address of current new_space
void **get_heap_fin() {
  LOG("[DEBUG] %s()\n", __func__);

  void **addr = gc.new_space - gc.heap_start + gc.space_capacity + (void **)GC_HEAP_OFFSET;

  void **result = (void **)((((uintptr_t)addr) << 1) + 1);
  LOG(" -> 0x%x", result);
  return result;
}

void *alloc_closure(INT8, void *f, uint8_t argc) {
  LOG("[DEBUG] %s(f: 0x%x, argc: %d)\n", __func__, f, argc);
  closure *clos = my_malloc(sizeof(closure) + sizeof(void *) * argc);

  clos->code = f;
  clos->argc = argc;
  clos->argc_recived = 0;
  memset(clos->args, 0, sizeof(void *) * argc);

  void *result = clos;
  LOG(" -> 0x%x\n", result);
  return result;
}

static void *copy_closure(closure *old_clos) {
  closure *clos = old_clos;
  closure *new = alloc_closure(ZERO8, clos->code, clos->argc);

  for (size_t i = 0; i < clos->argc_recived; i++) {
    new->args[new->argc_recived++] = clos->args[i];
  }

  return new;
}

// get closure and apply [argc] arguments to closure
void *apply_closure(INT8, closure *old_clos, uint8_t argc, ...) {
  argc = argc >> 1;
  void **args = malloc(sizeof(void *) * argc);

  va_list list;
  va_start(list, argc);
  for (size_t i = 0; i < argc; i++) {
    void *arg = va_arg(list, void *);
    args[i] = arg;
  }
  va_end(list);

  LOG("[Debug] %s(old_clos = {\n\tcode: 0x%x,\n\targc: %d\n\targc_recived: %d\n\targs = [", __func__, old_clos->code,
      old_clos->argc, old_clos->argc_recived);
  for (size_t i = 0; i < old_clos->argc_recived; i++) {
    LOG(i == 0 ? "0x%x" : ", 0x%x", old_clos->args[i]);
  }
  LOG("]\n}, argc: %d, args: [", argc);
  for (size_t i = 0; i < argc; i++) {
    LOG(i == 0 ? "0x%x" : ", 0x%x", args[i]);
  }
  LOG("])\n");
  fflush(stdout);

  closure *clos = copy_closure(old_clos);

  if (clos->argc_recived + argc > clos->argc) {
    LOG("Closure received %d args, get another %d args, but expect total %d args\n", clos->argc_recived, argc,
        clos->argc);
    fprintf(stdout, "Runtime error: function accept more arguments than expect\n");
    exit(122);
  }

  for (size_t i = 0; i < argc; i++) {
    clos->args[clos->argc_recived++] = args[i];
  }
  free(args);

  // if application is partial
  if (clos->argc_recived < clos->argc) {
    void *result = clos;
    LOG(" -> 0x%x\n", result);
    return result;
  }

  // full application (we need pass all arguments to stack and exec function)
  assert(clos->argc_recived == clos->argc);

  LOG(" -> *exec 0x%x*\n", old_clos->code);
  return call_closure(clos->code, clos->argc, clos->args);
}
