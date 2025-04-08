#include "utsname.h"
#include "syscall.h"
#include <string.h>

short uname(struct utsname *buf) {
  char nbuf[40];
  sysc_getinfo(nbuf);
  memcpy(buf, nbuf, 40);
  return 0;
}

/*char *n = "Manux Z80-PC 0.1-alpha Z80            ";
char *k = "Manux  ";
char *l = "Z80-PC ";
char *m = "0.1    ";
char *r = "alpha  ";
char *v = "Z80    ";
char *uname = "Manux   Z80-PC  0.1     alpha   Z80    ";*/