// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle
#ifndef DEVFS_H
#define DEVFS_H

#include "../../kernel/kernel.h"

#define DEVFS_MAX 8
#define DEVFS_ENTRY_SIZE 10

#define DEVFS_COUNT_ADDR KERNEL_WORKSPACE + 0x1FE
#define DEVFS_BASE_ADDR KERNEL_WORKSPACE + 0x200

typedef struct {
  char name[5];
  char type;
  char (*read_handler)(char *buf, short count);
  char (*write_handler)(char *buf, short count);
} dev_entry;

char devfs_init(void);
char devfs_open(char *name) __z88dk_fastcall;

void print_devices(void);

// tty drivers
char dev_tty_read(char *buf, short count);
char dev_tty_write(char *buf, short count);

// null/zero drivers
char dev_zero_read(char *buf, short count);
char dev_zero_write(char *buf, short count);


#endif