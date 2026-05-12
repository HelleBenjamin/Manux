// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025 Benjamin Helle

#include <sys/syscall.h>

/*
  Assembly syscall wrapper for C
*/

int syscall(unsigned char syscall_num, int arg1, int arg2, int arg3) __naked {

  __asm__ (
    "push ix\n"
    "ld ix, 0x0000\n"
    "add ix, sp\n"
    "ld a, (ix+0x04)\n" /* syscall number*/
    "ld l, (ix+0x05)\n" /* arg1 */
    "ld h, (ix+0x06)\n"
    "ld e, (ix+0x07)\n" /* arg2 */
    "ld d, (ix+0x08)\n"
    "ld c, (ix+0x09)\n" /* arg3 */
    "ld b, (ix+0x0a)\n"
    "rst 0x20\n" /* call syscall*/
    /* status in hl */
    "pop ix\n"
    "ret\n"
  );

  return 0;
}


