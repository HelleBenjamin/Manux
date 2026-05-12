// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025 Benjamin Helle

#ifndef UTSNAME_H
#define UTSNAME_H

#if defined(_LINUX)
#undef UTSNAME_H
#endif

typedef struct utsname {
  char sysname[9];
  char nodename[9];
  char release[9];
  char version[9];
  char machine[9];
} utsname;

int uname(struct utsname *buf) __z88dk_fastcall;

#endif