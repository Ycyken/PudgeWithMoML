#include <assert.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

typedef void *(*fun0)();
typedef void *(*fun8)(INT8);
typedef void *(*fun9)(INT8, void *);
typedef void *(*fun10)(INT8, void *, void *);
typedef void *(*fun11)(INT8, void *, void *, void *);
typedef void *(*fun12)(INT8, void *, void *, void *, void *);

#define WORD_SIZE (8)

// get closure and apply [argc] arguments to closure
void *apply_closure(INT8, void *f, uint8_t argc, ...) {
  closure *clos = f;
  va_list list;
  va_start(list, argc);

  if (clos->argc_recived + argc > clos->argc) {
    fprintf(stderr, "Runtime error: function accept more arguments than expect\n");
    exit(122);
  }

  // partial application
  if (clos->argc_recived + argc != clos->argc) {
    for (size_t i = 0; i < argc; i++) {
      void *arg = va_arg(list, void *);
      clos->args[clos->argc_recived++] = arg;
    }

    va_end(list);
    return clos;
  }

  // full application (we need pass all arguments to stack and exec function)
  // printf("FULL");
  for (size_t i = 0; i < argc; i++) {
    void *arg = va_arg(list, void *);
    clos->args[clos->argc_recived++] = arg;
  }
  assert(clos->argc_recived == clos->argc);
  va_end(list);

  switch (clos->argc) {
  case 1:
    return ((fun9)clos->code)(ZERO8, clos->args[0]);
  case 2:
    return ((fun10)clos->code)(ZERO8, clos->args[0], clos->args[1]);
  case 3:
    return ((fun11)clos->code)(ZERO8, clos->args[0], clos->args[1], clos->args[2]);
  case 4:
    return ((fun12)clos->code)(ZERO8, clos->args[0], clos->args[1], clos->args[2], clos->args[3]);
  default:
    exit(123);
  }

  // inspired by rukaml, alloca push arguments in stack
  // so we can exec function that use arguments only from stack

  // NOW DON'T WORK I DON'T KNOW WHY
  void **homka = alloca(WORD_SIZE * (clos->argc));
  for (size_t i = 0; i < clos->argc; i++) {
    homka[i] = clos->args[i];
  }
  fun8 func = clos->code;

  return func(ZERO8);
}