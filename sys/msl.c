// SPDX-License-Identifier: GPL-2.0-or-later
#include "msl.h"

/*Manux Standard Library*/

void memset(void *dest, int value, int size) {
  asm(
    "ld hl, 2\n"
    "add hl, sp\n"
    "ld e, (hl)\n" // Get size, de
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "push de\n"
    "ld c, (hl)\n" // Get value, bc
    "inc hl\n"
    "ld b, (hl)\n"
    "inc hl\n"
    "ld e, (hl)\n" // Get dest, hl
    "inc hl\n"
    "ld d, (hl)\n"
    "pop hl\n"
    "push af\n"
    "xor a\n"
    "memset_loop:\n"
    "ld (hl), c\n"
    "inc hl\n"
    "dec de\n"
    "cp e\n"
    "jp nz, memset_loop\n"
    "pop af"
  );
}
