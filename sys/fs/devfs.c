// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle
#include "devfs.h"
#include "../../include/stdio.h"
#include <string.h>

static dev_entry *devfs = (dev_entry *)DEVFS_BASE_ADDR;
static unsigned char *devfs_count = (char *)DEVFS_COUNT_ADDR;

// Initial device entries
static dev_entry predefined_devfs_entries[] = {
  {"tty ", 'c', (char *)dev_tty_read, (char *)dev_tty_write},
  {"zero", 'c', (char *)dev_zero_read, (char *)dev_zero_write},
  {"null", 'c', (char *)dev_zero_read, (char *)dev_zero_write}
};

char devfs_init(void) {
  *devfs_count = 3;
  memset(devfs, 0, DEVFS_MAX*DEVFS_ENTRY_SIZE); // Set all entries to 0
  memcpy(devfs, predefined_devfs_entries, sizeof(predefined_devfs_entries)); // Copy the predefined entries
  return 0;
}

char devfs_open(char *name) {
  for (unsigned char i = 0; i < DEVFS_MAX; ++i) {
    if (strcmp(name, predefined_devfs_entries[i].name) == 0) {
      return i; // Found the device
    }
  }
  return 0xFF; // Not found
}

// Print all devices
void print_devices(void) {
  for (unsigned char i = 0; i < *devfs_count; ++i) {
    puts(devfs[i].name);
    putchar(' ');
  }
}

// Read/write from/to main serial port
char dev_tty_read(char *buf, short count) {
  for (unsigned short i = 0; i < count; ++i) {
    buf[i] = getchar();
  }
  return 0;
}
char dev_tty_write(char *buf, short count) {
  for (unsigned short i = 0; i < count; ++i) {
    putchar(buf[i]);
  }
  return 0;
}

char dev_zero_read(char *buf, short count) {
  for (unsigned short i = 0; i < count; ++i) {
    buf[i] = 0;
  }
  return 0;
}
char dev_zero_write(char *buf, short count) {
  return 0;
}
