// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle
#include "../sys/shell.h"
#include "../sys/unistd.h"
#include "../sys/utsname.h"
#include "../sys/syscall.h"
#include "../sys/fs/mfs.h"
#include "../sys/fs/devfs.h"
#include "../sys/fd/fd.h"
#include "../include/stdio.h"

// This holds the system information
struct utsname uutsname;


int main(void) { // Root process, this initializes the kernel
  uname(&uutsname); // Get system information
  mfs_init(); // Init filesystem
  fd_init(); // Init file descriptors
  devfs_init(); // Init device filesystem
  fork(); // Create new process for shell
  syscall(SYS_EXEC, (short *)terminal, 0, 0); // Execute terminal
  while (1) {
    // This is the root process, it should never exit
    // If it exits, the system will crash
    // So we just wait here
    asm ("nop\n");
  }
  _exit(0); // Exit with code 0(success)
  return 0;
}