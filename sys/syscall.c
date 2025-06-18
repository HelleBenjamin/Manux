// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include "syscall.h"
#include "../include/stdio.h"
#include "fs/devfs.h"
#include "fs/mfs.h"
#include "fd/fd.h"
#include "unistd.h"

/*
  Assembly syscall wrapper for C
*/

void getparams3(void) {
  asm( // The name is the name of the function
    "public _getparams3\n"
    "public _getparams2\n"
    "public _getparams1\n"
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
    "push de\n"
    "ld e, (hl)\n" // 1st param, hl
    "inc hl\n"
    "ld d, (hl)\n"
    "ex de, hl\n"
    "pop de\n"
    "ret\n"
  );

}

void sysc_exit(short code) __z88dk_fastcall {
  asm(
    "extern SYSCALL_DISPATCH\n"
    "ld a, 0\n"
    "ld c, l\n"
    "call SYSCALL_DISPATCH"
  );
}

void sysc_write(char fd, short count, char *buf) {
  if (fd == STDOUT_FILENO) {
    sysc_puts(count, buf);
  } else if (fd == 0xFF) return; // Return if fd is null
  else {
    // TODO: Implement writing to multiple blocks
    unsigned short *addr;
    fd_get(fd, NULL, &addr); // Get the address where to write
    for (unsigned short i = 0; i < count; ++i) {
      addr[i] = buf[i];
    }
  }
}

void sysc_read(char fd, short count, char *buf) {
  if (fd == STDIN_FILENO) {
    sysc_gets(count, buf);
  } else if (fd == 0xFF) return; // Return if fd is null
  else {
    // TODO: Implement reading from multiple blocks
    unsigned short *addr;
    fd_get(fd, &addr, NULL); // Get the address where to read
    for (unsigned short i = 0; i < count; ++i) {
      buf[i] = addr[i];
    }
  }
}


void sysc_gets(short len, char *str) {
  asm(
    "call _getparams2\n"
    "ld a, 3\n"
    "call SYSCALL_DISPATCH"
  );
}

void sysc_puts(short len, char *str) {
  asm(
    "call _getparams2\n"
    "ld a, 4\n"
    "call SYSCALL_DISPATCH"
  );
}

void sysc_exec(short *addr) __z88dk_fastcall {
  asm(
    "ld a, 5\n"
    "call SYSCALL_DISPATCH"
  );
}

void sysc_getinfo(char *str) __z88dk_fastcall {
  asm(
    "ld a, 6\n"
    "call SYSCALL_DISPATCH"
  );
}

void sysc_rand(short *buf) __z88dk_fastcall {
  asm(
    "ld a, 7\n"
    "call SYSCALL_DISPATCH"
  );
}

void sysc_sleep(short ms) __z88dk_fastcall {
  // TODO
}

void sysc_fork(void) {
  asm(
    "ld a, 9\n"
    "call SYSCALL_DISPATCH"
  );
}

void sysc_getpid(char *buf) __z88dk_fastcall {
  asm(
    "ld a, 10\n"
    "call SYSCALL_DISPATCH"
  );
}

void sysc_getpcount(char *buf) __z88dk_fastcall {
  asm(
    "ld a, 11\n"
    "call SYSCALL_DISPATCH"
  );
}

void sysc_open(char *name, char *buf) {
  *buf = fd_create(name);
}

void sysc_close(char fd) __z88dk_fastcall {
  fd_close(fd);
}

void sysc_create(char *name) __z88dk_fastcall {
  create_file(name);
}

void sysc_execs(char *fname, char *arg) {
  asm(
    "call _getparams2\n"
    "ld a, 15\n"
    "call SYSCALL_DISPATCH"
  );
}