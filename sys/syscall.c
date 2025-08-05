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

short syscall(unsigned char syscall_num, short arg1, short arg2, short arg3) {
  /* Stack layout from current sp
    sp+0: return address
    sp+2: arg3 (BC)
    sp+4: arg2 (DE)
    sp+6: arg1 (HL)
    sp+8: syscall number (A)
  */
  if (syscall_num > 15) {
    return 0xFF; // Invalid syscall number
  }
  if (syscall_num == SYS_WRITE) sysc_write((char)arg1, arg2, (char *)arg3);
  else if (syscall_num == SYS_READ) sysc_read((char)arg1, arg2, (char *)arg3);

  asm(
    "call l_gint1sp\n" // arg3 (BC)
    "push hl\npop bc\n"
    "call l_gint4sp\n" // arg2 (DE)
    "push hl\npop de\n"
    "call l_gint8sp\n" // syscall number (A)
    "ld a, l\nex af, af'\n" // Save AF to AF'
    "call l_gint6sp\n" // arg1 (HL)
    "ex af, af'\n" // Restore AF
    //"extern REG_DUMP\n"
    //"call REG_DUMP\n"
    "extern SYSCALL_DISPATCH\n"
    "call SYSCALL_DISPATCH\n" // Call syscall dispatcher
  );
}

// Only C syscalls below
void sysc_write(char fd, short count, char *buf) {
  if (fd == STDOUT_FILENO) {
    syscall(SYS_PUTS, (char *)buf, count, 0);
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
    syscall(SYS_GETS, (char *)buf, count, 0);
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
