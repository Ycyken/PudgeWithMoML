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

void *alloc_closure(void *f, uint8_t argc) {
  closure *clos = malloc(sizeof(closure) + sizeof(void *) * argc);

  clos->code = f;
  clos->argc = argc;
  clos->argc_recived = 0;
  memset(clos->args, 0, sizeof(void *) * argc);

  return clos;
}

#define ZERO8 0, 0, 0, 0, 0, 0, 0, 0
#define INT8 int, int, int, int, int, int, int, int

typedef void *(*fun9)(INT8, void *);
typedef void *(*fun10)(INT8, void *, void *);
typedef void *(*fun11)(INT8, void *, void *, void *);
typedef void *(*fun12)(INT8, void *, void *, void *, void *);

void *apply_1(void *f, void *arg1) {
  closure *clos = f;

  if (clos->argc_recived + 1 > clos->argc) {
    fprintf(stderr,
            "Runtime error: function accept more arguments than expect\n");
    exit(122);
  }

  // partial application
  if (clos->argc_recived + 1 != clos->argc) {
    clos->args[clos->argc_recived++] = arg1;
    return clos;
  }

  // full applcation
  if (clos->argc == 1) {
    clos->args[clos->argc_recived++] = arg1;
    fun9 func = clos->code;
    return func(ZERO8, clos->args[0]);
  } else if (clos->argc == 2) {
    clos->args[clos->argc_recived++] = arg1;
    fun10 func = clos->code;
    return func(ZERO8, clos->args[0], clos->args[1]);
  } else if (clos->argc == 3) {
    clos->args[clos->argc_recived++] = arg1;
    fun11 func = clos->code;
    return func(ZERO8, clos->args[0], clos->args[1], clos->args[2]);
  } else if (clos->argc == 4) {
    clos->args[clos->argc_recived++] = arg1;
    fun12 func = clos->code;
    return func(ZERO8, clos->args[0], clos->args[1], clos->args[2],
                clos->args[3]);
  }
}

void *apply_2(void *f, void *arg1, void *arg2) {
  closure *clos = f;

  if (clos->argc_recived + 2 > clos->argc) {
    fprintf(stderr,
            "Runtime error: function accept more arguments than expect\n");
    exit(122);
  }

  // partial application
  if (clos->argc_recived + 2 != clos->argc) {
    clos->args[clos->argc_recived++] = arg1;
    clos->args[clos->argc_recived++] = arg2;
    return clos;
  }

  // full applcation
  clos->args[clos->argc_recived++] = arg1;
  clos->args[clos->argc_recived++] = arg2;
  if (clos->argc == 2) {
    clos->args[clos->argc_recived++] = arg1;
    fun10 func = clos->code;
    return func(ZERO8, clos->args[0], clos->args[1]);
  } else if (clos->argc == 3) {
    clos->args[clos->argc_recived++] = arg1;
    fun11 func = clos->code;
    return func(ZERO8, clos->args[0], clos->args[1], clos->args[2]);
  } else if (clos->argc == 4) {
    clos->args[clos->argc_recived++] = arg1;
    fun12 func = clos->code;
    return func(ZERO8, clos->args[0], clos->args[1], clos->args[2],
                clos->args[3]);
  }
}

void *apply_3(void *f, void *arg1, void *arg2, void *arg3) {
  closure *clos = f;

  if (clos->argc_recived + 3 > clos->argc) {
    fprintf(stderr,
            "Runtime error: function accept more arguments than expect\n");
    exit(122);
  }

  // partial application
  if (clos->argc_recived + 3 != clos->argc) {
    clos->args[clos->argc_recived++] = arg1;
    clos->args[clos->argc_recived++] = arg2;
    clos->args[clos->argc_recived++] = arg3;
    return clos;
  }

  // full applcation
  clos->args[clos->argc_recived++] = arg1;
  clos->args[clos->argc_recived++] = arg2;
  clos->args[clos->argc_recived++] = arg3;
  fun12 func = clos->code;
  return func(ZERO8, clos->args[0], clos->args[1], clos->args[2],
              clos->args[3]);
}