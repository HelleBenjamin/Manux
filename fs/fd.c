// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025-2026 Benjamin Helle
#include <fs/fd.h>
#include <fs/mfs.h>
#include <string.h>

fd_entry fd_table[FD_MAX];
int fd_count; /* Number of open file descriptors*/

int fd_init(void) {
  memset(fd_table, 0, sizeof(fd_entry)*FD_MAX);
  fd_count = 3; /* Reserve for stdin, stdout and stderr*/
  fd_table[0].type = FD_TYPE_STDIN;
  fd_table[0].flags = FD_FLAGS_READ;
  fd_table[1].type = FD_TYPE_STDOUT;
  fd_table[1].flags = FD_FLAGS_WRITE;
  fd_table[2].type = FD_TYPE_STDERR;
  fd_table[2].flags = FD_FLAGS_WRITE;

  return 0;
}

fd_entry *fd_get(int fd) {
  /* Return pointer to fd entry*/
  if (fd < 0 || fd >= FD_MAX) return NULL; /* out of bounds */
  if (fd == -1) return NULL;
  return &fd_table[fd];
}

int fd_alloc(void) {
  for (unsigned char i = 0; i < FD_MAX; ++i) {
    if (fd_table[i].type == FD_TYPE_NONE) {
      return i; // Found an empty entry
    }
  }
  return -1;
}

int fd_close(int fd) __z88dk_fastcall {
  if (fd < 3 || fd >= FD_MAX) return 1; /* prevent closing system fds, and out of bounds check*/
  if (fd == -1) return -1;
  fd_entry *entry = &fd_table[fd];
  if (entry->type == FD_TYPE_FILE && entry->file != NULL) { /* if file, close and save it*/
    mfs_close(fd);
  }

  memset(entry, 0, sizeof(fd_entry)); /* zero the entry*/

  --fd_count;

  return 0;
}

int fd_create(fd_entry *entry) __z88dk_fastcall {
  int fd = fd_alloc();
  if (fd == -1) return -1; // No free entries

  memcpy(&fd_table[fd], entry, sizeof(fd_entry)); /* Copy the entry to the main table*/

  ++fd_count;
  return fd;
}
