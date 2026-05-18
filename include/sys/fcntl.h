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

/* file create */
#define O_CREAT     0x200

/* implemented in sys/unistd dir*/
extern int open(const char *path, int flags, int mode);

extern int creat(const char *path, int mode);

#endif