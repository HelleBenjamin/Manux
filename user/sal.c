// Copyright (c) 2025 Benjamin Helle
// SPDX-License-Identifier: GPL-2.0-or-later

#include "sal.h"
#ifdef linux
#include <unistd.h>
#include <stdio.h>
int main() {
  sal_main();
  return 0;
}
#else
#include "sys/unistd.h"
#include "include/stdio.h"
#endif

// Symbolic Assembly Language, SymAsm
// Why? Wouldn't it be fun if you couldn't write any code at all? Even though it's a very simple language, it's still fun to play with.
// You can run this interpreter code both Linux and Manux without any modifications, thanks to the unistd.h and stdio.h includes. To run execute 'gcc user/sal.c -o sal' command.
// Here's a hello world program: >H.<E.<L..<O.<_.<W..<O..<R..<L..<D.h

static char stack[STACK_SIZE]; // Program stack
static short sp = STACK_SIZE; // Stack pointer
static char halt = 0; // halt flag

void nl(void) { puts("\n\r"); }

void interpret(char *line) {
  char temp = 0;
  switch (line[0]) {
    case '+': // Increment stack pointer
      ++sp;
      break;
    case '-': // Decrement stack pointer
      --sp;
      break;
    case '>': // Push ASCII immediate value to stack
      --sp;
      stack[sp] = line[1];
      break;
    case '<': // Set top of stack to ASCII immediate value
      stack[sp] = line[1];
      break;
    case ':': // Duplicate top of stack
      --sp;
      stack[sp] = stack[sp + 1];
      break;
    case '.': // Print character from stack
      putchar(stack[sp]);
      nl();
      break;
    case ',': // Read character to stack
      // TODO: Fix this, it's sometimes buggy
      stack[sp] = getchar();
      break;

    // Arithmetic operations
    case 'a': // Add
      temp = stack[sp] + stack[sp+1];
      sp += 2;
      stack[sp] = temp;
      break;
    case 's': // Subtract
      temp = stack[sp] - stack[sp+1];
      sp += 2;
      stack[sp] = temp;
      break;

    case 'h': // Halt
      halt = 1;
      break;

    default:
      break;
  }
}

void sal_main(void) {
  static char line[2];
  sp = STACK_SIZE;
  halt = 0;
  // A buffer would be better than interpreting line by line, but executing line by line, the size of the program is basically unlimited
  while (!halt) {
    read(STDIN_FILENO, &line, 2); // read a line
    nl();
    interpret(line); // execute it then loop until halt
  }

}