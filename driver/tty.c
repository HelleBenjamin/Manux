/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/

#include <driver/tty.h>
#include <kernel/kernel.h>

__sfr __at 0x81 TTY_DATA;
__sfr __at 0x80 TTY_CONTROL;

uint8_t* tty_buffer_tail;
uint8_t* tty_buffer_head;
uint8_t* tty_buffer_count;
uint8_t* tty_buffer;


int tty_init(void) {
  /* 6850 ACIA initialization */
  TTY_CONTROL = 0x03; /* master reset */
  TTY_CONTROL = 0x96; /* 64 clock divider, 8 bits 1 stop bit, rx interrupt enabled, adjust if needed */
  tty_buffer_tail = (uint8_t*)TTY_BUF_TAIL;
  tty_buffer_head = (uint8_t*)TTY_BUF_HEAD;
  tty_buffer_count = (uint8_t*)TTY_BUF_COUNT;
  tty_buffer = (uint8_t*)TTY_BUF;
  *tty_buffer_count = 0;
  *tty_buffer_head = tty_buffer;
  *tty_buffer_tail = tty_buffer;
  return 0;
}

void z80_rst_38h(void) __critical __interrupt(0x38) {
  if (*tty_buffer_count < TTY_BUF_SIZE) {
    tty_buffer[*tty_buffer_head] = TTY_DATA;
    *tty_buffer_head = (*tty_buffer_head + 1) % TTY_BUF_SIZE;
    *tty_buffer_count = *tty_buffer_count + 1;
  }
}

void z80_rst_08h(void) __naked {
  __asm__ ( /* put character in a*/
    "out (0x81), a\n"
    "ei\n"
    "reti\n"
  );
}

void z80_rst_10h(void) __interrupt(0x10) {
  volatile char character;
  while(*tty_buffer_count == 0);
  character = tty_buffer[*tty_buffer_tail];
  *tty_buffer_tail = (*tty_buffer_tail + 1) % TTY_BUF_SIZE;
  *tty_buffer_count = *tty_buffer_count - 1;
  TTY_DATA = character; /* echo*/
  __asm__ (
    "ld a, (ix-2)\n" /* character in A*/
    "ld sp, ix\n"
    "pop ix\n"
    "pop iy\n"
    "pop hl\n"
    "pop de\n"
    "pop bc\n"
    "inc sp\n" /* skip AF*/
    "inc sp\n"
    "ei\n"
    "reti\n"
  );
}

int tty_getchar(void) {
  char character;
  while(*tty_buffer_count == 0);
  character = tty_buffer[*tty_buffer_tail];
  *tty_buffer_tail = (*tty_buffer_tail + 1) % TTY_BUF_SIZE;
  *tty_buffer_count = *tty_buffer_count - 1;
  return character;
}

int tty_putchar(char c) __z88dk_fastcall {
  TTY_DATA = c;
  return 0;
}