// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle
#ifndef FD_H
#define FD_H

#include "../../kernel/kernel.h"

#define FD_MAX 8
#define FD_ENTRY_SIZE 5
#define FD_COUNT_ADDR KERNEL_WORKSPACE + 0xFE
#define FD_BASE_ADDR KERNEL_WORKSPACE + 0x100

typedef struct {
  char state;
  unsigned short* read_ptr;
  unsigned short* write_ptr;
} fd_entry;

char fd_init(void);
char fd_alloc(void);
char fd_close(char fd) __z88dk_fastcall;
char fd_create(char *fname) __z88dk_fastcall;
char fd_get(char fd, unsigned short *r_ptr, unsigned short *w_ptr);
//char dump_fd(char fd); // Debug only

#endif