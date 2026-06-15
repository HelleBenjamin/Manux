/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2026 Benjamin Helle
* m80asm.c
* simple z80 assembler
* can assemble VERY simple programs
*/

/* this is very barebones, supports small subset of z80 instructions */
/* I wrote this initially in a day, so it needs proper testing and bug fixing, and optimization*/

/* CHANGELOG */
/* 
2026-06-08: 
  Initial release, first version

2026-06-11: 
  Added label support, two-pass system, minor bug fixes, added few instructions

2026-06-15:
  Implemented more instructions, bug fixes, renamed to "m80asm"

2026-06-16:
  Added index instructions

*/

#ifdef __linux
#include <unistd.h>
#include <fcntl.h>
#else
/* Manux libraries */
#include <sys/unistd.h>
#include <sys/fcntl.h>
#endif
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>

int outputfd; /* output file descriptor */
uint16_t pc = 0x4100; /* program counter, keeps track of current address, defaults to 0x4100 */
int pass = 0; /* pass number, 0 first pass: collect labels, pass 1: codegen*/

struct label {
  char name[20];
  uint16_t address; /* absolute addr*/
};

struct label labels[16]; /* array of label structures, size can be adjusted */
int num_labels = 0; /* number of labels found */

int get_label_addr(char *name) {
  if (!pass) return -1; /* pass not completed*/
  for (uint8_t i = 0; i < num_labels; i++) {
    if (strcmp(labels[i].name, name) == 0) { /* label found */
      return labels[i].address;
    }
  }
  return -1; /* label not found */
}

/* emit byte*/
void emitb(uint8_t b) {
  pc++; /* increment pc even when not generating, needed for labels*/
  if (!pass) return; /* don't emit during first pass */
  write(outputfd, &b, 1);
}

/* emit word */
void emitw(uint16_t w) {
  /* little endian */
  if (!pass) {
    pc += 2;
    return;
  }
  emitb(w & 0xff);
  emitb((w >> 8) & 0xff);
}

int emit_rel(char *addr, uint16_t base_pc) {
  /* check if label*/
  int num;
  int label = get_label_addr(addr);
  if (label != -1) {
    num = label;
  } else { /* not label, immediate value*/
    if (!pass) { /* placeholder byte during first pass for unresolved label */
      emitb(0);
      return 0;
    }
    num = strtol(addr, NULL, 0);
  }
  int offset;

  /* if fit in 8-bit signed range */
  if (num >= -128 && num <= 127) {
    emitb((uint8_t)(num));
    return 0;
  }

  /* if fit in 8-bit unsigned range */
  if (num >= 0 && num <= 0xFF) {
    emitb((uint8_t)(int8_t)(num));
    return 0;
  }

  /* else calculate relative offset and emit it */
  offset = num - (int)(base_pc+2);
  if (offset < -128 || offset > 127) {
    return -1; /* offset out of range */
  }
  emitb((uint8_t)offset);
  return 0;
}

int reg8(char *name) {
  /* return register "index"*/
  if (strcmp(name, "B") == 0) return 0;
  if (strcmp(name, "C") == 0) return 1;
  if (strcmp(name, "D") == 0) return 2;
  if (strcmp(name, "E") == 0) return 3;
  if (strcmp(name, "H") == 0) return 4;
  if (strcmp(name, "L") == 0) return 5;
  if (strcmp(name, "(HL)") == 0) return 6;
  if (strcmp(name, "A") == 0) return 7;
  return -1; /* invalid register */
}

int reg16(char *name) {
  /* for add/sub, push/pop, etc..*/
  if (strcmp(name, "BC") == 0) return 0;
  if (strcmp(name, "DE") == 0) return 1;
  if (strcmp(name, "HL") == 0) return 2;
  if (strcmp(name, "SP") == 0 || strcmp(name, "AF") == 0) return 3; /* note: af is invalid in some operations, such as addition, there's no "add hl, af"*/
  return -1;
}

int index_reg(char *name) {
  /* for index register operations*/
  /* returns prefix*/
  if (strcmp(name, "IX") == 0) return 0xDD;
  if (strcmp(name, "IY") == 0) return 0xFD;
  return -1;
}

int jpcond(char *name) {
  /* jump condition*/
  if (strcmp(name, "NZ") == 0) return 0;
  if (strcmp(name, "Z") == 0) return 1;
  if (strcmp(name, "NC") == 0) return 2;
  if (strcmp(name, "C") == 0) return 3;
  if (strcmp(name, "PO") == 0) return 4;
  if (strcmp(name, "PE") == 0) return 5;
  if (strcmp(name, "P") == 0)  return 6;
  if (strcmp(name, "M") == 0)  return 7;
  return -1; /* invalid condition */
}

int jrcond(char *name) {
  /* jump relative condition*/
  if (strcmp(name, "NZ") == 0) return 0;
  if (strcmp(name, "Z") == 0) return 1;
  if (strcmp(name, "NC") == 0) return 2;
  if (strcmp(name, "C") == 0) return 3;
  return -1;
}

int mem_addr(char *addr) {
  /* parses memory address, like (0x30) to number 0x30*/
  if (addr[0] == '(' && addr[strlen(addr) - 1] == ')') {
    addr[strlen(addr) - 1] = '\0';
    return strtol(addr + 1, NULL, 0);
  }
  return -1; /* invalid memory address */
}

int index_addr(char *str, int *prefix, int *disp) {
  char buf[32];
  int len = strlen(str);

  /* check if valid*/
  if (len < 5) return -1;
  if (str[0] != '(' || str[len - 1] != ')') return -1;

  /* copy the inxed register*/
  strncpy(buf, str+1, len - 2);
  buf[len-2] = 0; /* null*/

  /* now set the prefix according to the register*/
  if (strncmp(buf, "IX", 2) == 0) {
    *prefix = 0xDD;
  } else if (strncmp(buf, "IY", 2) == 0) {
    *prefix = 0xFD;
  } else {
    return -1; /* invalid index reg*/
  }

  if (buf[2] != '+' && buf[2] != '-') return -1; /* only +- offsets are accepted, no modrm like stuff*/

  /* set the displacement*/
  *disp = strtol(buf+2, NULL, 0);

  /* check if in bounds*/
  if (*disp < -128 || *disp > 127) return -1;

  return 0;
}

/* single pass code generation, needs to be dual pass to support labels */
int line_codegen(char *line) {
  /* global variables, makes debugging easier */
  char op[20];
  char arg1[20];
  char arg2[20];
  int reg1, reg2; /* 8-bit registers */
  int rr; /* 16-bit register */
  int cond; /* condition, for jumps, etc.*/
  int addr; /* absolute address */
  int imm; /* immediate value*/
  int label_addr; /* resolved label address, second pass only */
  int prefix, disp; /* index stuff*/

  /* remove comments */
  if (line[0] == ';') {
    return 0; /* if line starts with a comment, skip*/
  }
  for (int i = 0; line[i]; i++) {
    if (line[i] == ';') {
      line[i] = '\0';
      break;
    }
  }

  /* make line uppercase */
  for (int i = 0; line[i] != '\0'; i++) {
    line[i] = toupper(line[i]);
  }

  /* tokenize line with strtok */
  /* operation*/
  char *token = strtok(line, " \t");
  if (!token) return 0; /* ignore empty lines */
  strncpy(op, token, sizeof(op) - 1);
  op[sizeof(op) - 1] = '\0';
  /* check if label, ends with colon*/
  if (op[strlen(op) - 1] == ':') {
    op[strlen(op) - 1] = '\0';
    if (!pass) {
      if (num_labels >= (int)(sizeof(labels)/sizeof(labels[0]))) {
        printf("Too many labels\n");
        return -1;
      }
      strncpy(labels[num_labels].name, op, sizeof(labels[num_labels].name) - 1);
      labels[num_labels].name[sizeof(labels[num_labels].name) - 1] = '\0';
      labels[num_labels].address = pc; /* current code position*/
      num_labels++;
      return 0;
    }
    return 0;
  }

  /* argument 1*/
  token = strtok(NULL, " \t,");
  if (token) {
    strncpy(arg1, token, sizeof(arg1) - 1);
    arg1[sizeof(arg1) - 1] = '\0';
  } else {
    arg1[0] = '\0';
  }

  /* argument 2*/
  token = strtok(NULL, " \t,");
  if (token) {
    strncpy(arg2, token, sizeof(arg2) - 1);
    arg2[sizeof(arg2) - 1] = '\0';
  } else {
    arg2[0] = '\0';
  }

  /* codegen part*/
  /* no argument operation first(easiest to implement)*/
  if (strcmp(op, "NOP") == 0) { emitb(0x00); return 0; }
  if (strcmp(op, "HALT") == 0) { emitb(0x76); return 0; }
  if (strcmp(op, "DI") == 0) { emitb(0xF3); return 0; }
  if (strcmp(op, "EI") == 0) { emitb(0xFB); return 0; }
  if (strcmp(op, "CPL") == 0) { emitb(0x2F); return 0; }
  if (strcmp(op, "SCF") == 0) { emitb(0x37); return 0; }
  if (strcmp(op, "CCF") == 0) { emitb(0x3F); return 0; }
  if (strcmp(op, "DAA") == 0) { emitb(0x27); return 0; }
  if (strcmp(op, "RLCA") == 0) { emitb(0x07); return 0; }
  if (strcmp(op, "RRCA") == 0) { emitb(0x0F); return 0; }
  if (strcmp(op, "RLA") == 0) { emitb(0x17); return 0; }
  if (strcmp(op, "RRA") == 0) { emitb(0x1F); return 0; }
  if (strcmp(op, "EXX") == 0) { emitb(0xD9); return 0; }

  /* now comes the argument-based operations */
  /* load/store*/
  if (strcmp(op, "LD") == 0) {
    /* 8-bit operations first */
    reg1 = reg8(arg1);
    reg2 = reg8(arg2);

    /* index address*/
    /* it needs to be first because of the design*/
    if (index_addr(arg2, &prefix, &disp) == 0) {
      /* LD r, (IX/IY+disp)*/
      if (reg1 != -1 && reg1 != 6) {
        emitb(prefix); /* 0xDD or 0xFD*/
        emitb(0x46+(reg1 << 3));
        emitb((uint8_t)disp);
        return 0;
      }
    }

    if (index_addr(arg1, &prefix, &disp) == 0) {
      /* LD (IX/IY+disp), r*/
      if (reg2 != -1 && reg2 != 6) {
        emitb(prefix);
        emitb(0x70+(reg2 << 3));
        emitb((uint8_t)disp);
        return 0;
      }

      /* LD (IX/IY+disp), n*/
      imm = strtol(arg2, NULL, 0);
      emitb(prefix);
      emitb(0x36);
      emitb((uint8_t)disp);
      emitb(imm);
      return 0;
    }

    /* both are registers */
    if (reg1 != -1 && reg2 != -1) {
      if (reg1 == 6 && reg2 == 6) return -1; /* not possible */
      emitb(0x40 + (reg1 << 3) + reg2); /* or reg2 * 8, but shift is more efficient */
      return 0;
    }

    /* only arg1 is a register, arg2 is an immediate value */
    if (reg1 != -1) {
      imm = strtol(arg2, NULL, 0);
      emitb(0x06 + (reg1 << 3));
      emitb(imm);
      return 0;
    }


    /* 16-bit operations */
    rr = reg16(arg1);

    /* LD SP, IX/IY*/
    prefix = index_reg(arg2);
    if (strcmp(arg1, "SP") == 0 && prefix != -1) {
      emitb(prefix);
      emitb(0xF9);
      return 0;  
    }

    /* immediate*/
    if (rr != -1) {
      imm = strtol(arg2, NULL, 0);
      emitb(0x01 + (rr << 4));
      emitw(imm);
      return 0;
    }

    /* LD IX/IY, nn*/
    prefix = index_reg(arg1);
    if (prefix != -1) {
      imm = strtol(arg2, NULL, 0);
      emitb(prefix);
      emitb(0x21);
      emitw(imm);
      return 0;
    }

    /* special 16-bit ops, */
    if ((strcmp(arg1, "A") == 0) && (strcmp(arg2, "(BC)") == 0)) { emitb(0x0A); return 0; }
    if ((strcmp(arg1, "A") == 0) && (strcmp(arg2, "(DE)") == 0)) { emitb(0x1A); return 0; }
    if ((strcmp(arg1, "(BC)") == 0) && (strcmp(arg2, "A") == 0)) { emitb(0x02); return 0; }
    if ((strcmp(arg1, "(DE)") == 0) && (strcmp(arg2, "A") == 0)) { emitb(0x12); return 0; }

    /* absolute address */
    addr = mem_addr(arg2);
    if (strcmp(arg1, "A") == 0 && addr >= 0) {
      /* LD A, (nn) */
      emitb(0x3A);
      emitw((uint16_t)addr);
      return 0;
    }
    if (strcmp(arg1, "HL") == 0 && addr >= 0) {
      /* LD HL, (nn) */
      emitb(0x2A);
      emitw((uint16_t)addr);
      return 0;
    }

    addr = mem_addr(arg1);
    if (strcmp(arg2, "A") == 0 && addr >= 0) {
      /* LD (nn), A */
      emitb(0x32);
      emitw((uint16_t)addr);
      return 0;
    }
    if (strcmp(arg2, "HL") == 0 && addr >= 0) {
      /* LD (nn), HL */
      emitb(0x22);
      emitw((uint16_t)addr);
      return 0;
    }

    prefix = index_reg(arg2);
    if (prefix != -1) {
      /* LD (nn), IX/IY*/
      emitb(prefix);
      emitb(0x22);
      emitw((uint16_t)addr);
      return 0;
    }

    if (strcmp(arg1, "SP") == 0 && strcmp(arg2, "HL") == 0) {
      emitb(0xF9);
      return 0;
    }
  }

  /* increment */
  if (strcmp(op, "INC") == 0) {
    reg1 = reg8(arg1);
    if (reg1 != -1) {
      emitb(0x04 + (reg1 << 3));
      return 0;
    }

    /* 16-bit*/
    rr = reg16(arg1);
    if (rr != -1) {
      emitb(0x03 + (rr << 4));
      return 0;
    }

    prefix = index_reg(arg1);
    if (prefix != -1) {
      emitb(prefix);
      emitb(0x23);
      return 0;
    }
  }
  /* decrement */
  if (strcmp(op, "DEC") == 0) {
    reg1 = reg8(arg1);
    if (reg1 != -1) {
      emitb(0x05 + (reg1 << 3));
      return 0;
    }

    /* 16-bit*/
    rr = reg16(arg1);
    if (rr != -1) {
      emitb(0x0B + (rr << 4));
      return 0;
    }

    prefix = index_reg(arg1);
    if (prefix != -1) {
      emitb(prefix);
      emitb(0x2B);
      return 0;
    }
  }

  /* add*/
  if (strcmp(op, "ADD") == 0) {
    /* 8bit*/
    if (strcmp(arg1, "A") == 0) {
      reg1 = reg8(arg2);
      if (reg1 != -1) {
        emitb(0x80 + reg1);
        return 0;
      }

      /* immediate */
      imm = strtol(arg2, NULL, 0);
      emitb(0xC6);
      emitb(imm);
      return 0;
    }

    /* 16 bit*/
    if (strcmp(arg1, "HL") == 0) {
      rr = reg16(arg2);
      if (rr != -1) {
        emitb(0x09 + (rr << 4));
        return 0;
      }
    }

    /* index register, IX/IY*/
    prefix = index_reg(arg1);
    if (prefix != -1) {
      rr = reg16(arg2);
      if (rr != -1) {
        emitb(prefix);
        emitb(0x09 + (rr << 4));
        return 0;
      }
    }
  }

  /* add with carry*/
  if (strcmp(op, "ADC") == 0) {
    if (strcmp(arg1, "A") != 0) return -1;
    reg1 = reg8(arg2);
    if (reg1 != -1) {
      emitb(0x88 + reg1);
      return 0;
    }

    /* immediate */
    imm = strtol(arg2, NULL, 0);
    emitb(0xCE);
    emitb(imm);
    return 0;
  }

  /* subtract */
  if (strcmp(op, "SUB") == 0) {
    reg1 = reg8(arg1);
    if (reg1 != -1) {
      emitb(0x90 + reg1);
      return 0;
    }

    /* immediate */
    imm = strtol(arg1, NULL, 0);
    emitb(0xD6);
    emitb(imm);
    return 0;
  }

  /* subtract with carry*/
  if (strcmp(op, "SBC") == 0) {
    if (strcmp(arg1, "A") != 0) return -1;
    reg1 = reg8(arg2);
    if (reg1 != -1) {
      emitb(0x98 + reg1);
      return 0;
    }

    /* immediate */
    imm = strtol(arg2, NULL, 0);
    emitb(0xDE);
    emitb(imm);
    return 0;
  }

  /* logical operations */
  if (strcmp(op, "AND") == 0 || strcmp(op, "OR") == 0 || strcmp(op, "XOR") == 0 || strcmp(op, "CP") == 0) {
    int base = 0; /* base opcode with register */
    int imm_base = 0; /* immediate opcode */

    if (strcmp(op, "AND") == 0) {
      base = 0xA0;
      imm_base = 0xE6;
    } else if (strcmp(op, "OR") == 0) {
      base = 0xB0;
      imm_base = 0xF6;
    } else if (strcmp(op, "XOR") == 0) {
      base = 0xA8;
      imm_base = 0xEE;
    } else if (strcmp(op, "CP") == 0) {
      base = 0xB8;
      imm_base = 0xFE;
    }

    /* register */
    reg1 = reg8(arg1);
    if (reg1 != -1) {
      emitb(base + reg1);
      return 0;
    }

    /* immediate */
    imm = strtol(arg1, NULL, 0);
    emitb(imm_base);
    emitb(imm);
    return 0;
  }

  /* push/pop*/
  if (strcmp(op, "PUSH") == 0) {
    rr = reg16(arg1);
    if (rr != -1) {
      emitb(0xC5 + (rr << 4));
      return 0;
    }

    prefix = index_reg(arg1);
    if (prefix != -1) {
      emitb(prefix);
      emitb(0xE5);
      return 0;
    }
  }
  if (strcmp(op, "POP") == 0) {
    rr = reg16(arg1);
    if (rr != -1) {
      emitb(0xC1 + (rr << 4));
      return 0;
    }

    prefix = index_reg(arg1);
    if (prefix != -1) {
      emitb(prefix);
      emitb(0xE1);
      return 0;
    }
  }

  /* reset vectors */
  if (strcmp(op, "RST") == 0) {
    imm = strtol(arg1, NULL, 0);
    if (imm >= 0 && imm <= 0x38) {
      emitb(0xC7 + imm);
      return 0;
    }
  }

  /* jump absolute */
  if (strcmp(op, "JP") == 0) {
    /* JP (HL)*/
    if (strcmp(arg1, "(HL)") == 0) {
      emitb(0xE9);
      return 0;
    }

    /* JP cond, nn*/
    if (arg2[0] != 0) {
      cond = jpcond(arg1);
      if (cond == -1) return -1;
      emitb(0xC2 + (cond << 3));
      label_addr = get_label_addr(arg2);
      if (label_addr != -1) {
        emitw(label_addr);
      } else { /* not label, raw address*/
        imm = strtol(arg2, NULL, 0);
        emitw(imm);
      }
      return 0;
    }

      /* JP nn */
    if (arg1[0] != 0) {
      emitb(0xC3);
      label_addr = get_label_addr(arg1);
      if (label_addr != -1) {
        emitw(label_addr);
      } else {
        imm = strtol(arg1, NULL, 0);
        emitw(imm);
      }
      return 0;
    }
  }

  /* jump relative, from current position */
  if (strcmp(op, "JR") == 0) {
    int curr_pc = pc;

    /* JR cond, d*/
    if (arg2[0] != 0) {
      cond = jrcond(arg1);
      if (cond == -1) return -1;
      emitb(0x20 + (cond << 3));
      return emit_rel(arg2, curr_pc);
    }

    /* JR d */
    if (arg1[0] != 0) {
      emitb(0x18);
      return emit_rel(arg1, curr_pc);
    }
  }

  /* call */
  if (strcmp(op, "CALL") == 0) {
    /* CALL cond, nn*/
    if (arg2[0] != 0) {
      cond = jpcond(arg1);
      if (cond == -1) return -1;
      emitb(0xC4 + (cond << 3));
      label_addr = get_label_addr(arg2);
      if (label_addr != -1) {
        emitw(label_addr);
      } else { /* not label, raw address*/
        imm = strtol(arg2, NULL, 0);
        emitw(imm);
      }
      return 0;
    }

    /* CALL nn */
    if (arg1[0] != 0) {
      emitb(0xCD);
      label_addr = get_label_addr(arg1);
      if (label_addr != -1) {
        emitw(label_addr);
      } else {
        imm = strtol(arg1, NULL, 0);
        emitw(imm);
      }
      return 0;
    }
  }

  /* return */
  if (strcmp(op, "RET") == 0) {
    /* RET cond*/
    if (arg1[0] != 0) {
      cond = jpcond(arg1);
      if (cond == -1) return -1;
      emitb(0xC0 + (cond << 3));
    } else { /* unconditional RET*/
      emitb(0xC9);
    }
    return 0;
  } 

  /* IO*/
  if (strcmp(op, "IN") == 0) {
    /* IN A, (n) */
    if (strcmp(arg1, "A") == 0 && arg2[0] != 0) {
      imm = mem_addr(arg2);
      emitb(0xDB);
      emitb(imm);
      return 0;
    }
  }
  if (strcmp(op, "OUT") == 0) {
    /* OUT (n), A */
    if (strcmp(arg2, "A") == 0 && arg1[0] != 0) {
      imm = mem_addr(arg1);
      emitb(0xD3);
      emitb(imm);
      return 0;
    }
  }

  if (strcmp(op, "DJNZ") == 0) {
    int curr_pc = pc;
    emitb(0x10);
    return emit_rel(arg1, curr_pc);
  }

  /* exchange*/
  if (strcmp(op, "EX") == 0) {
    
    if (strcmp(arg1, "AF") == 0 && strcmp(arg2, "AF'") == 0) {
      emitb(0x08);
      return 0;
    }
    if (strcmp(arg1, "DE") == 0 && strcmp(arg2, "HL") == 0) {
      emitb(0xEB);
      return 0;
    }
    if (strcmp(arg1, "(SP)") == 0 && strcmp(arg2, "HL") == 0) {
      emitb(0xE3);
      return 0;
    }
  }

  return -1;
}


int main(int argc, char *argv[]) {
  if (argc < 3) {
    printf("Usage: ./m80asm.bin <input.asm> <output.bin> <additional_args>\n");
    return -1;
  }

  /* additional args 
    * --org <addr> - start address
  */

  uint16_t basepc = pc;

  /* parse additional arguments */
  for (int i = 3; i < argc; i++) {
    if (strcmp(argv[i], "--org") == 0 && i + 1 < argc) {
      basepc = (uint16_t)strtol(argv[i + 1], NULL, 0);
      i++;
    }
  }

  /* takes the input and output file names */
  printf("m80asm - Manux Z80 assembler\n");

  /* random */
  printf("%s -> %s\n", argv[1], argv[2]);

  /* open the input file */
  int infd = open(argv[1], O_RDONLY, 0);
  if (infd == -1) {
    printf("Couldn't open input file\n");
    return -1;
  }

  int input_size = lseek(infd, 0, SEEK_END);
  lseek(infd, 0, SEEK_SET); /* simple size get hack*/

  /* open the output file */
  outputfd = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644);
  if (outputfd == -1) {
    printf("Couldn't open output file\n");
    return -1;
  }

  /* main loop doing the assembly */
  /* read line by line and assemble by it*/
  /* the assembly is completed in two passes:*/
  /* 1st pass: collect labels, dummy emits to get pc position*/
  /* 2nd pass: actual code generation*/
  char line[127];
  for (pass = 0; pass < 2; pass++) {
    printf("Begin pass %d\n", pass+1);
    pc = basepc; /* reset the program counter */
    /* rewind input file for each pass */
    lseek(infd, 0, SEEK_SET);
    int line_number = 0; /* debug */
    while (1) {
      int i = 0;
      int code = 1; /* default to error*/
      memset(line, 0, 127);
      /* read until newline */
      for (; i < sizeof(line) - 1; i++) {
        code = read(infd, &line[i], 1);
        if (code <= 0) break;
        if (line[i] == '\n') {
          line[i] = '\0';
          break;
        }
      }

      if (code == 0 && i == 0) {
        /* end of file */
        break;
      }

      if (code < 0) { /* error reading it*/
        printf("Error reading input file\n");
        break;
      }

      line[i] = '\0'; /* null terminate */

      if (line_codegen(line) < 0) { /* assemble the line*/
        printf("Error assembling line: %s\n", line);
        break;
      }
      line_number++;
    }
  }

  /* print the size, more like a debug function*/
  printf("Assembled program size %d bytes\n", pc - basepc);

  close(infd);
  close(outputfd);

  return 0;
}