// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025 Benjamin Helle
#ifndef FD_H
#define FD_H

#include <kernel/kernel.h>
#include <fs/mfs.h>
#include <stdint.h>

/* Max number of file descriptors*/
#define FD_MAX 8

/* FD types */
#define FD_TYPE_NONE   0
#define FD_TYPE_STDIN  1
#define FD_TYPE_STDOUT 2
#define FD_TYPE_STDERR 3
#define FD_TYPE_FILE   4

#define FD_FLAGS_READ  1
#define FD_FLAGS_WRITE 2

typedef struct {
  uint8_t type; /* file, etc..*/
  uint8_t flags; /* read write*/
  uint16_t pos;
  uint16_t cur_block; /* current block */
  uint16_t prev_block; /* previous block */
  uint16_t block_offset; /* byte offset */
  file* file;
} fd_entry;

extern fd_entry fd_table[FD_MAX];
extern int fd_count;

fd_entry *fd_get(int fd);

int fd_init(void);
int fd_alloc(void);
int fd_close(int fd) __z88dk_fastcall;
int fd_create(fd_entry *entry) __z88dk_fastcall;

#endif