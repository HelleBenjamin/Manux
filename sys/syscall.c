#include "syscall.h"


#pragma define CRT_ENABLE_STDIO=0

/*
  This file implements syscalls in C API
*/

void sysc_exit(short code) __z88dk_fastcall {
  asm(
    "ld a, 0\n"
    "ld c, l\n"
    "call $B000"
  );
}

void sysc_write(short port, short len, char *str) {
  asm(
    "ld hl, 2\n"
    "add hl, sp\n"
    "ld e, (hl)\n" // Get address
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "push de\n"
    "ld c, (hl)\n" // Get port
    "inc hl\n"
    "ld b, (hl)\n"
    "inc hl\n"
    "ld e, (hl)\n" // Get len
    "inc hl\n"
    "ld d, (hl)\n"
    "pop hl\n"
    "ld a, 1\n"
    "call $B000"
  );
}

void sysc_read(short port, short len, char *str) {
  asm(
    "ld hl, 2\n"
    "add hl, sp\n"
    "ld e, (hl)\n" // Get address
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "push de\n"
    "ld c, (hl)\n" // Get port
    "inc hl\n"
    "ld b, (hl)\n"
    "inc hl\n"
    "ld e, (hl)\n" // Get len
    "inc hl\n"
    "ld d, (hl)\n"
    "pop hl\n"
    "ld a, 2\n"
    "call $B000"
  );
}

void sysc_gets(short len, char *str) {
  asm(
    "ld hl, 2\n"
    "add hl, sp\n"
    "ld e, (hl)\n" // Get address
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "push de\n"
    "ld e, (hl)\n" // Get len
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "pop hl\n"
    "ld a, 3\n"
    "call $B000"
  );
}

void sysc_puts(short len, char *str) {
  asm(
    "ld hl, 2\n"
    "add hl, sp\n"
    "ld e, (hl)\n" // Get address
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "push de\n"
    "ld e, (hl)\n" // Get len
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "pop hl\n"
    "ld a, 4\n"
    "call $B000"
  );
}

void sysc_exec(short len, short *addr) {
  asm(
    "ld hl, 2\n"
    "add hl, sp\n"
    "ld e, (hl)\n" // Get address
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "push de\n"
    "ld e, (hl)\n" // Get len
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "pop hl\n"
    "ld a, 5\n"
    "call $B000"
  );
}

void sysc_getinfo(char *str) {
  asm(
    "ld hl, 2\n"
    "add hl, sp\n"
    "ld e, (hl)\n" // Get address
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "push de\n"
    "pop hl\n"
    "ld a, 6\n"
    "call $B000"
  );
}

void sysc_rand(short *buf) {
  asm(
    "ld hl, 2\n"
    "add hl, sp\n"
    "ld e, (hl)\n" // Get address
    "inc hl\n"
    "ld d, (hl)\n"
    "inc hl\n"
    "push de\n"
    "pop hl\n"
    "ld a, 7\n"
    "call $B000"
  );
}
