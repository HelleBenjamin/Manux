// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025 Benjamin Helle
#ifndef MFS_H
#define MFS_H

#include <stdint.h>
#include <sys/types.h>


#define BLOCK_SIZE    512 /* Single sector */
#define MAX_FILES     12
#define MAX_FNAME_LEN 12

#define CHECKSUM      0xBEEF 

#define FS_BUF        0xF000 /* Single sector sized buffer */
#define FS_ROOT_MADDR 0xF200 /* Start of root directory in RAM */

#define FS_ROOT_SECTOR  0 /* Start of Root directory */
#define FS_BLOCK_SECTOR (FS_ROOT_SECTOR+1) /* Start of File blocks */
#define FS_MAX_SECTORS  2879 /* Max sectors that the FS can use - root sector */

/* file flags*/
#define FRO      0x01
#define FWO      0x02
#define FRW      0x03

/* from sys/fcntl.h */
/* file open */
#define O_RDONLY    0x00
#define O_WRONLY    0x01
#define O_RDWR      0x02
#define O_ACCMODE   0x03
#define	O_APPEND	  0x08	

/* file create */
#define O_CREAT     0x200
#define O_TRUNC     0x400

/* seek */
#define SEEK_SET    0x01
#define SEEK_CUR    0x02
#define SEEK_END    0x03

typedef struct {
  uint8_t   used; /* used flag */
  uint8_t   flags; /* file flags, read/write*/
  uint8_t   id; /* file id*/
  char      name[12];
  uint16_t  size; /* file size on bytes */
  uint8_t   block_size; /* number of blocks allocated */
  uint16_t  block;   /* Start block */
} file; /* 20 bytes*/

/* Root FS structure */
typedef struct {
  uint16_t  checksum;
  uint8_t   formatted;
  uint8_t   filecount;
  file      files[MAX_FILES];
} MFS;

/* misc functions */
uint16_t find_free_block(void);
file* find_file(char *fname) __z88dk_fastcall;
uint16_t get_file_size(char *fname) __z88dk_fastcall;
uint16_t get_file_block(char *fname) __z88dk_fastcall;
int load_executable(char *fname, uint16_t addr); /* Load file to memory(and makes it executable),*/
uint8_t get_file_index(char *fname) __z88dk_fastcall;
void write_changes(void);

/* Main functions that should be used*/
int mfs_init(void);
int mfs_format(void);
int mfs_exit(void);
int mfs_open(char *fname, int flags);
int mfs_close(int fd) __z88dk_fastcall;
int mfs_read(int fd, char *buf, uint16_t count);
int mfs_write(int fd, char *buf, uint16_t count);
int mfs_sync(void);
int mfs_delete(char *fname) __z88dk_fastcall;
int mfs_seek(int fd, uint16_t pos, int whence);
int dump_fs(void);
int mfs_list(char *buf) __z88dk_fastcall;
int mfs_filesize(char *fname) __z88dk_fastcall;

/* Disk functions(assembly wrappers) */
int disk_read(char *buffer, uint16_t sector, uint8_t num_sectors);
int disk_write(char *buffer, uint16_t sector, uint8_t num_sectors);


#endif