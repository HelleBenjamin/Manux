// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle
#include "mfs.h"
#include "../../include/stdio.h"
#include <string.h>
#include <stdint.h>

/*
; Here's a (very) basic description of the file system:
; MFS 1.0 (Memory Filesystem, Manux Filesystem)
; Similar to the FAT (File Allocation Table)
; old name FIFS (Flat Index Filesystem)
; 8 byte filenames
; 256 byte blocks
;
; File structure:
; 1 byte flag(used/free)
; 8 byte name
; 2 byte size
; 1 byte block size
; 2 byte ptr to first block
;
; Block structure:
; 1 byte flag(used/free)
; 2 byte next block ptr
; 1 align byte
; n bytes data
*/

static file *files = (file *)FS_ADDRESS+2;
static unsigned short *filecount = (short *)FS_ADDRESS;
static unsigned short *block_ptr = (short *)BLOCK_ADDRESS;
static file *tempfile;
static unsigned short *fs_ptr = (short *)FS_ADDRESS;
// Define variables in static to make the code faster and smaller
static unsigned short remaining;
static unsigned short *block;
static unsigned short bytes_in_block;

void mfs_init(void) {
  memset(fs_ptr, 0, 0xFFF); // Format file system
  *filecount = 0;
}

short* find_free_block(void) {
  for (unsigned char i = 0; i < 0xFF; i++) {
    block_ptr = (unsigned short *)(BLOCK_ADDRESS+BLOCK_SIZE*i);
    if (block_ptr[0] == 0) {
      return block_ptr;
    }
  }
  return NULL;
}

file* find_file(char *fname) __z88dk_fastcall {
  for (unsigned char i = 0; i < *filecount; ++i) {
    if (strcmp(fname, files[i].name) == 0) {
      return &files[i];
    }
  }
  return NULL;
}

short* get_file_blockptr(char *fname) __z88dk_fastcall { // Returns first block of file
  for (unsigned char i = 0; i < *filecount; ++i) {
    if (strcmp(fname, files[i].name) == 0) {
      return files[i].block_ptr;
    }
  }
  return NULL;
}

char read_file(char *fname, short count, char *buf) {
  tempfile = find_file(fname);
  if (tempfile == NULL) return 0xFF;

  remaining = count;
  block = tempfile->block_ptr;

  while (remaining != 0 && block != NULL) {
    bytes_in_block = (remaining > BLOCK_SIZE-4) ? (BLOCK_SIZE-4) : remaining;

    for (unsigned short i = 0; i < bytes_in_block; ++i) {
      buf[i] = block[i+4];
    }

    buf += bytes_in_block;
    remaining -= bytes_in_block;
    block = (unsigned short *)block[1];
  }

  return 0;
}

char write_file(char* fname, short count, char *buf) {
  tempfile = find_file(fname);
  if (tempfile == NULL) return 0xFF;

  remaining = count;
  block = tempfile->block_ptr;

  tempfile->size = count;
  tempfile->block_size = 0;

  while (remaining != 0) {
    ++tempfile->block_size;
    // Calculate bytes in block
    bytes_in_block = (remaining > BLOCK_SIZE-4) ? (BLOCK_SIZE-4) : remaining;

    // Write to block
    for (unsigned short i = 0; i < bytes_in_block; ++i) {
      block[i+4] = buf[i];
    }

    buf += bytes_in_block;
    remaining -= bytes_in_block;
    if (remaining <= 0) {
      block[1] = 0; // last block
      break;
    }

    short *next_block = find_free_block();
    if (next_block == NULL) return 0xFF; // Exit if no free block
    block[1] = (unsigned short)next_block;
    block = (unsigned short *)next_block;
  }

  return 0; // Success
}

char create_file(char *fname) {
  unsigned short *block = find_free_block();
  if (block == NULL || *filecount >= MAX_FILES || find_file(fname) != NULL) { // Throw error
    return 0xFF; // No free blocks 
  }

  // TODO: Add file overwrite, add file deletion, make a function that looks for free file entry

  strncpy(files[*filecount].name, &fname[0], MAX_FILE_NAME_LENGTH); // Copy file name
  files[*filecount].used = 1; // Set file entry to used
  files[*filecount].size = 0; // Initialize to 0
  files[*filecount].block_size = 1; // Set block size to 1 (first block)
  files[*filecount].block_ptr = block; // Copy the file block

  block[0] = 1; // Set block to used
  block[1] = 0; // Set next block to 0
  block[2] = 0;

  ++(*filecount);

  return 0; // Success
}

void list_files(void) {
  for (unsigned char i = 0; i < *filecount; ++i) {
    puts(files[i].name);
    putchar(' ');
  }
}

short get_file_size(char *fname) {
  tempfile = find_file(fname);
  if (tempfile == NULL) return 0xFF;
  return tempfile->size;
}