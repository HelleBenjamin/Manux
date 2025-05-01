#include "sys/unistd.h"

int main() {
  write(STDOUT_FILENO, "Hello World!\n\r", 14);
  _exit(0);
}
