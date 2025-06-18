// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle
#ifndef MFS_H
#define MFS_H

#include "../../kernel/kernel.h"

#define BLOCK_SIZE 256
#define MAX_FILES 8
#define MAX_FILE_NAME_LENGTH 8
#define FS_ADDRESS 0xF000
#define BLOCK_ADDRESS 0xF100

typedef struct {
  char used;
  char name[8];
  unsigned short size;
  unsigned char block_size;
  unsigned short *block_ptr;
} file;

void mfs_init(void);
short* find_free_block(void);
file* find_file(char *fname) __z88dk_fastcall;
short* get_file_blockptr(char *fname) __z88dk_fastcall;
char read_file(char *fname, short count, char *buf);
char write_file(char *fname, short count, char *buf);
char create_file(char *fname) __z88dk_fastcall;
void list_files(void);
short get_file_size(char *fname) __z88dk_fastcall;

#endif