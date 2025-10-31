#include <assert.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void *call_closure(void *code, uint64_t argc, void **argv);

void print_int(int n) { printf("%d\n", n); }

void flush() { fflush(stdout); }

typedef struct {
  void *code;
  uint8_t argc;
  uint8_t argc_recived;
  void *args[];
} closure;

#define ZERO8 0, 0, 0, 0, 0, 0, 0, 0
#define INT8 int, int, int, int, int, int, int, int

void *alloc_closure(INT8, void *f, uint8_t argc) {
  closure *clos = malloc(sizeof(closure) + sizeof(void *) * argc);

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
  va_list list;
  va_start(list, argc);

  if (clos->argc_recived + argc > clos->argc) {
    fprintf(stderr, "Runtime error: function accept more arguments than expect\n");
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
