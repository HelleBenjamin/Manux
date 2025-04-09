#include "shell.h"
#include "unistd.h"
#include "utsname.h"
#include <string.h>

/*
  Simple shell for Manux. This provides minimal interface for the kernel.
*/

unsigned char hextobyte(char *hex) {
  unsigned char byte = 0;
  if (hex[0] >= '0' && hex[0] <= '9') {
    byte += (hex[0] - '0') << 4;
  } else if (hex[0] >= 'A' && hex[0] <= 'F') {
    byte += (hex[0] - 'A' + 10) << 4;
  }
  if (hex[1] >= '0' && hex[1] <= '9') {
    byte += (hex[1] - '0');
  } else if (hex[1] >= 'A' && hex[1] <= 'F') {
    byte += (hex[1] - 'A' + 10);
  }
  return byte;
}

void z80ld() {
  // Very small Z80 program loader, loads hex code to 0xF000
  char *program = (char *)0xF000;
  char pg[0xFF] = {0};
  read(STDIN_FILENO, &pg, 0xFF);
  for (short i = 0; i < 0xFF; i++) {
    program[i] = hextobyte(&pg[i * 2]);
  }
  write(STDOUT_FILENO, "\n\r", 2);
  asm("call 0xF000");
}

void terminal() {
  char command[32] = {0};
  while (1) {
    memset(command, 0, 32);
    write(STDOUT_FILENO, "> ", 2);
    read(STDIN_FILENO, &command, 32);
    write(STDOUT_FILENO, "\n\r", 2);
    if (strcmp(command, "Z$") == 0) {
      ZHEX();
    } else if (strcmp(command, "exit") == 0) {
      _exit(0);
    } else if (strcmp(command, "uname") == 0) {
      struct utsname utsname;
      uname(&utsname);
      write(STDOUT_FILENO, utsname.sysname, 8);
      write(STDOUT_FILENO, utsname.nodename, 8);
      write(STDOUT_FILENO, utsname.release, 8);
      write(STDOUT_FILENO, utsname.version, 8);
      write(STDOUT_FILENO, utsname.machine, 8);
      write(STDOUT_FILENO, "\n\r", 2);
    } else if (strcmp(command, "z80ld") == 0) {
      z80ld();
    } else if (strcmp(command, "clear") == 0) {
      char clear = 0x0C;
      write(STDOUT_FILENO, &clear , 1);
    }
  }
  

}

void main() {
  struct utsname sname;
  uname(&sname);
  write(STDOUT_FILENO, sname.sysname, 8);
  write(STDOUT_FILENO, "\n\r", 2);
  terminal();
}

void ZHEX() { // Z$ (Z-hex)
  unsigned char memarray[0xff] = {0};
  unsigned char program[0xff] = {0};
  unsigned char mempointer = 0;
  unsigned short i = 0;

  write(STDOUT_FILENO, "Z$>", 3);
  read(STDIN_FILENO, &program, 0xFF);

  while(i < 0xFF){
    switch(program[i]) {
      case '+':
        ++memarray[mempointer];
        break;
      case '-':
        --memarray[mempointer];
        break;
      case '>':
        write(STDOUT_FILENO, &memarray[mempointer], 1);
        break;
      case ';':
        if(memarray[mempointer] == 0){
          --mempointer;
        } else {
          ++mempointer;
        }
        break;
      default:
        break;
    }
    i++;
  }
  write(STDOUT_FILENO, "\n\r", 2);
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>++>------>

void OS_ENTRY() {
  main();
  return;
}