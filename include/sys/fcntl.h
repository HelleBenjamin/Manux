/*SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/
#ifndef __FCNTL_H__
#define __FCNTL_H__

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
#define SEEK_SET    0x00
#define SEEK_CUR    0x01
#define SEEK_END    0x02

/* implemented in sys/unistd dir*/
extern int open(const char *path, int flags, ...);

extern int creat(const char *path, int mode);

#endif