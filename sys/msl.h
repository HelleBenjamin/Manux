// SPDX-License-Identifier: GPL-2.0-or-later

#ifndef MSL_H
#define MSL_H

/*Manux Standard Library*/

#include "syscall.h"
#include "utsname.h"
#include "unistd.h"

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned long uint32_t;
typedef unsigned long long uint64_t;

typedef signed char int8_t;
typedef signed short int16_t;
typedef signed long int32_t;
typedef signed long long int64_t;

void memset(void *dest, int value, int size);
void memcpy(void *dest, void *src, int size);
void memcmp(void *dest, void *src, int size);

int strcmp(const char *s1, const char *s2);
int strlen(const char *s);

#endif