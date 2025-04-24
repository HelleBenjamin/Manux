// SPDX-License-Identifier: GPL-2.0-or-later

#include "syscall.h"

/*
  Assembly syscall wrapper for C
*/

void getparams3(void) {
  asm( // The name is the name of the function
    "ld hl, 4\n"
    "add hl, sp\n"
    "ld e, (hl)\n" // 3rd param, hl
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "push de\n"
    "ld e, (hl)\n" // 2nd param, de
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "ld c, (hl)\n" // 1st param, bc
    "inc hl\n"
    "ld b, (hl)\n"
    "pop hl\n"
    "ret\n"
  );
  asm(
    "_getparams2:\n"
    "ld hl, 4\n"
    "add hl, sp\n"
    "ld e, (hl)\n" // 2nd param, hl
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "push de\n"
    "ld e, (hl)\n" // 1st param, de
    "inc hl\n"
    "ld d, (hl)\n"
    "pop hl\n"
    "ret\n"
  );
  asm(
    "_getparams1:\n"
    "ld hl, 4\n"
    "add hl, sp\n"
    "ld e, (hl)\n" // 1st param, hl
    "inc hl\n"
    "ld d, (hl)\n"
    "ex de, hl\n"
    "ret\n"
  );

}

void sysc_exit(short code) __z88dk_fastcall {
  asm(
    "ld a, 0\n"
    "ld c, l\n"
    "call $B000"
  );
}

void sysc_write(short port, short len, char *str) {
  asm(
    "call _getparams3\n"
    "ld a, 1\n"
    "call $B000"
  );
}

void sysc_read(short port, short len, char *str) {
  asm(
    "call _getparams3\n"
    "ld a, 2\n"
    "call $B000"
  );
}

void sysc_gets(short len, char *str) {
  asm(
    "call _getparams2\n"
    "ld a, 3\n"
    "call $B000"
  );
}

void sysc_puts(short len, char *str) {
  asm(
    "call _getparams2\n"
    "ld a, 4\n"
    "call $B000"
  );
}

void sysc_exec(short *addr) __z88dk_fastcall {
  asm(
    "ld a, 5\n"
    "call $B000"
  );
}

void sysc_getinfo(char *str) __z88dk_fastcall {
  asm(
    "ld a, 6\n"
    "call $B000"
  );
}

void sysc_rand(short *buf) __z88dk_fastcall {
  asm(
    "ld a, 7\n"
    "call $B000"
  );
}

void sysc_sleep(short ms) {
  // TODO
}

void sysc_fork(void) {
  asm(
    "ld a, 9\n"
    "call $B000"
  );
}

void sysc_getpid(char *buf) __z88dk_fastcall {
  asm(
    "ld a, 10\n"
    "call $B000"
  );
}

void sysc_getpcount(char *buf) __z88dk_fastcall {
  asm(
    "ld a, 11\n"
    "call $B000"
  );
}
