// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#ifndef UTSNAME_H
#define UTSNAME_H

#if defined(_LINUX)
#undef UTSNAME_H
#endif

typedef struct utsname {
  char sysname[8];
  char nodename[8];
  char release[8];
  char version[8];
  char machine[8];
} utsname;

short uname(struct utsname *buf);

#endif