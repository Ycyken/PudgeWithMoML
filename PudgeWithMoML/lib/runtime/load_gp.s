    .text
    .globl load_gp
    .type  load_gp, @function
# Initialize gp pointer
# Took from https://github.com/bminor/glibc/blob/00d406e77bb0e49d79dc1b13d7077436ee5cdf14/sysdeps/riscv/start.S#L82
load_gp:
.option push
.option norelax
  lla   gp, __global_pointer$
.option pop
  ret

  .section .preinit_array,"aw"
  .align 8
  .dc.a load_gp

/* Define a symbol for the first piece of initialized data.  */
  .data
  .globl __data_start
__data_start:
  .weak data_start
  data_start = __data_start
