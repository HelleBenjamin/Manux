#ifndef FEMU80_H
#define FEMU80_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#define MEM_SIZE 0xFFFF // 64k

#define FLAG_C 0x01
#define FLAG_N 0x02
#define FLAG_P 0x04
#define FLAG_H 0x20
#define FLAG_Z 0x40
#define FLAG_S 0x80

#define ALU_OP_ADD 0x00
#define ALU_OP_ADC 0x01
#define ALU_OP_SUB 0x02
#define ALU_OP_SBC 0x03
#define ALU_OP_AND 0x04
#define ALU_OP_OR 0x05
#define ALU_OP_XOR 0x06
#define ALU_OP_CP 0x07
#define ALU_OP_INC 0x08
#define ALU_OP_DEC 0x09
#define ALU_OP_RLC 0x0A
#define ALU_OP_RL 0x0B
#define ALU_OP_RRC 0x0C
#define ALU_OP_RR 0x0D
#define ALU_OP_SLA 0x0E
#define ALU_OP_SRA 0x0F
#define ALU_OP_SRL 0x10
#define ALU_OP_BIT 0x11
#define ALU_OP_RES 0x12
#define ALU_OP_SET 0x13

uint8_t fByte(VirtZ80 *cpu);
uint16_t fWord(VirtZ80 *cpu);
void loadLow(uint16_t *reg, uint8_t value);
void loadHigh(uint16_t *reg, uint8_t value);
uint8_t getHigh(uint16_t reg);
uint8_t getLow(uint16_t reg);
void exchange(uint16_t *reg1, uint16_t *reg2);


typedef struct {
  // Registers
  uint16_t af, bc, de, hl, afa, bca, dea, hla; // General purpose registers and shadow registers
  uint16_t ix, iy; // Index Y and X
  uint16_t pc, sp; // Program counter, stack pointer
  uint16_t wz; // Temp register
  uint8_t i, r; // Interrupt, dram refresh
  uint8_t im; // Interrupt mode
  bool iff1, iff2;
  // Memory
  uint8_t memory[MEM_SIZE];
  bool halt;
  uint64_t cycles; // CPU cycles
} VirtZ80;

#endif