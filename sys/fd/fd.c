// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle
#include "fd.h"
#include "../fs/mfs.h"
#include "../../include/stdio.h"
#include "../syscall.h"
#include <string.h>

static fd_entry *fd_table = (fd_entry *)FD_BASE_ADDR;
static unsigned short *fd_base = (short *)FD_BASE_ADDR;
static unsigned char *fd_count = (char *)FD_COUNT_ADDR;


char fd_init(void) {
  memset(fd_base, 0, FD_MAX*FD_ENTRY_SIZE);
  *fd_count = 3; // First 3 entries are reserved for stdin, stdout and stderr)
  fd_table[0].state = 1;
  fd_table[1].state = 1;
  fd_table[2].state = 1;
  return 0;
}

char fd_alloc(void) {
  unsigned short entry_ptr = 0;
  for (unsigned char i = 0; i < FD_MAX; ++i) {
    if (fd_table[i].state == 0) {
      return i; // Found an empty entry
    }
  }
  return 0xFF;
}

char fd_close(char fd) __z88dk_fastcall {
  if (fd == 0xFF) return 0xFF;
  --(*fd_count);
  fd_table[fd].state = 0;
  return 0;
}

char fd_create(char *fname) __z88dk_fastcall {
  char fd = fd_alloc();
  if (fd == 0xFF) return 0xFF; // No free entries

  unsigned short *block_ptr = get_file_blockptr(fname); // Get the first block pointer
  if (block_ptr == NULL) return 0xFF; // File does not exist

  fd_table[fd].state = 1; // Set entry to used
  fd_table[fd].read_ptr = (unsigned short *)(block_ptr+4); // Assign read and write pointers
  fd_table[fd].write_ptr = (unsigned short *)(block_ptr+4);

  ++(*fd_count);
  return fd;
}

char fd_get(char fd, unsigned short *r_ptr, unsigned short *w_ptr) {
  if (fd == 0xFF) return 0xFF; // Invalid fd
  if (r_ptr) {
    *r_ptr = fd_table[fd].read_ptr;
  }
  if (w_ptr) {
    *w_ptr = fd_table[fd].write_ptr;
  }
  return 0;
}

// Debug only
/*char dump_fd(char fd) {
  puts("FD: ");
  puth(fd);
  puts(" State: ");
  puth(fd_table[fd].state);
  puts(" r_ptr: ");
  puth(fd_table[fd].read_ptr);
  puts(" w_ptr: ");
  puth(fd_table[fd].write_ptr);
  return 0;
}*/