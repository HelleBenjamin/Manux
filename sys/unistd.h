#ifndef _UNISTD_H
#define _UNISTD_H

#include "sys/syscall.h"
#include <stdlib.h>

/*
  Very small POSIX API implementation.
  Works for IO only
*/

#ifndef NULL
#define NULL (void *)0
#endif
#ifndef ssize_t
#define ssize_t int
#endif

#define STDIN_FILENO 0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

void _exit(short code);
ssize_t read(int fd, void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count);

#endif