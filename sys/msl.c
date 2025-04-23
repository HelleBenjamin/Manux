// SPDX-License-Identifier: GPL-2.0-or-later
#include "msl.h"
#include "syscall.h"

/*Manux Standard Library*/

void memset(void *dest, int value, int size) {
  asm(
    "extern _getparams3\n"
    "extern _getparams2\n"
    "call _getparams3\n"
    "ex de, hl\n" // DE = size
    "push hl\n"
    "push bc\n"
    "pop hl\n" // HL = dest
    "pop bc\n" // BC = value

    "push af\n"
    "xor a\n"
    "memset_loop:\n"
    "ld (hl), c\n"
    "inc hl\n"
    "dec de\n"
    "cp e\n"
    "jp nz, memset_loop\n"
    "pop af\n"
  );
}

void memcpy(void *dest, void *src, int size) {
  asm(
    "call _getparams3\n"
    "push hl\n"
    "push de\n"
    "push bc\n"
    "pop de\n" // DE = dest
    "pop hl\n" // HL = src
    "pop bc\n" // BC = size
    "ldir\n" // Simple as it gets, just a single instruction
  );
}

void memcmp(void *dest, void *src, int size) {
  asm(
    "call _getparams3\n"
    "push hl\n"
    "push de\n"
    "push bc\n"
    "pop de\n" // DE = dest
    "pop hl\n" // HL = src
    "pop bc\n" // BC = size
    "memcmp_loop:\n"
    "ld a, (de)\n"
    "cpi\n"
    "inc de\n"
    "jp nz, memcmp_loop\n"
  );
}

int strcmp(const char *s1, const char *s2) {
  while (*s1 == *s2) {
    if (*s1 == '\0') {
      return 0;
    }
    s1++;
    s2++;
  }
  return 1;
}

int strlen(const char *s) {
  int len = 0;
  while (s[len] != '\0') {
    len++;
  }
  return len;
}

int putchar(char c) {
  sysc_puts(1, &c);
  return c;
}

int puts(char *s) {
  short len = strlen(s);
  sysc_puts(len, s);
  return len;
}

char getchar(void) {
  char *c = '\0';
  sysc_gets(1, c);
  return *c;
}