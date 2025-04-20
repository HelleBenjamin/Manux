#include "femu80.h"

// Fast Emulator for Z80

void execute(VirtZ80 *cpu) {
  while (!cpu->halt) {
    cpu->r += 1;
    MainInstruction(cpu);
  }
}


uint8_t fByte(VirtZ80 *cpu) {
  return cpu->memory[cpu->pc++];
}

uint16_t fWord(VirtZ80 *cpu) {
  uint16_t result = cpu->memory[cpu->pc++];
  result |= cpu->memory[cpu->pc++] << 8;
  return result;
}

void loadLow(uint16_t *reg, uint8_t value) {
  *reg &= 0xFF00;
  *reg |= value;
}

void loadHigh(uint16_t *reg, uint8_t value) {
  *reg &= 0x00FF;
  *reg |= value << 8;
}

uint8_t getHigh(uint16_t reg) {
  return reg >> 8;
}

uint8_t getLow(uint16_t reg) {
  return reg & 0xFF;
}

void exchange(uint16_t *reg1, uint16_t *reg2) {
  uint16_t temp = *reg1;
  *reg1 = *reg2;
  *reg2 = temp;
}

void push(VirtZ80 *cpu, uint16_t value) {
  cpu->sp--;
  cpu->memory[cpu->sp] = value >> 8;
  cpu->sp--;
  cpu->memory[cpu->sp] = value & 0xFF;
}

uint16_t pop(VirtZ80 *cpu) {
  uint16_t result = cpu->memory[cpu->sp++];
  result |= cpu->memory[cpu->sp++] << 8;
  return result;
}

void setCoreRoutines() {

}

void updateFlags8(VirtZ80 *cpu, uint16_t alu_result) {
  cpu->af = (cpu->af & ~(FLAG_Z | FLAG_S | FLAG_C | FLAG_H | FLAG_P)) |
            (alu_result == 0 ? FLAG_Z : 0x00) |
            (alu_result & 0x80 ? FLAG_S : 0x00) |
            (alu_result & 0x10 ? FLAG_H : 0x00) |
            (alu_result & 0x100 ? FLAG_C : 0x00) |
            ((alu_result & 0x0F) + (cpu->af & FLAG_C ? 1 : 0) > 0xF ? FLAG_P : 0x00);
}

void updateFlags16(VirtZ80 *cpu, uint32_t alu_result) {
  cpu->af = (cpu->af & ~(FLAG_Z | FLAG_S | FLAG_C | FLAG_H | FLAG_P)) |
            (alu_result == 0 ? FLAG_Z : 0x00) |
            (alu_result & 0x8000 ? FLAG_S : 0x00) |
            (alu_result & 0x10000 ? FLAG_C : 0x00) |
            (alu_result & 0x100 ? FLAG_H : 0x00) |
            (alu_result < -32768 || alu_result > 32767 ? FLAG_P : 0x00);
}

uint8_t getFlag(VirtZ80 *cpu, uint8_t flag) {
  return cpu->af & flag;
}

void OutputHandler(uint8_t port, uint8_t value) {
  if (port == 0x01) putchar(value); // STDOUT
}

uint8_t InputHandler(uint8_t port) {
  if (port == 0x00) return getchar(); // STDIN
  return 0;
}

void alu8(VirtZ80 *cpu, uint8_t* dest, uint8_t value, uint8_t ins) {
  if (!dest) {
    return;
  }
  uint16_t result = 0;
  switch (ins) {
    case ALU_OP_ADD:
      result = *dest + value;
      break;
    case ALU_OP_ADC:
      result = *dest + value + getFlag(cpu, FLAG_C);
      break;
    case ALU_OP_SUB:
      result = *dest - value;
      break;
    case ALU_OP_SBC:
      result = *dest - value - getFlag(cpu, FLAG_C);
      break;
    case ALU_OP_AND:
      result = *dest & value;
      break;
    case ALU_OP_OR:
      result = *dest | value;
      break;
    case ALU_OP_XOR:
      result = *dest ^ value;
      break;
    case ALU_OP_CP:
      result = *dest - value;
      updateFlags8(cpu, result);
      return;
    case ALU_OP_INC:
      result = *dest + 1;
      break;
    case ALU_OP_DEC:
      result = *dest - 1;
      break;

    case ALU_OP_RLC:
      result = (*dest << 1) | (*dest >> 7);
      break;
    case ALU_OP_RRC:
      result = (*dest >> 1) | (*dest << 7);
      break;
    case ALU_OP_RL:
      result = (*dest << 1) | getFlag(cpu, FLAG_C);
      break;
    case ALU_OP_RR:
      result = (*dest >> 1) | getFlag(cpu, FLAG_C) << 7;
      break;
    case ALU_OP_SLA:
      result = (*dest << 1);
      break;
    case ALU_OP_SRA:
      result = (*dest >> 1) | (*dest & 0x80);
      break;
    case ALU_OP_SRL:
      result = (*dest >> 1);
      break;

    case ALU_OP_BIT:
      result = *dest & (1 << value);
      updateFlags8(cpu, result);
      return;
    case ALU_OP_RES:
      result = *dest & ~(1 << value);
      break;
    case ALU_OP_SET:
      result = *dest | (1 << value);
      break;

    default:
      return;
  }

  updateFlags8(cpu, result);
  *dest = (result & 0xFF);
}

void alu16(VirtZ80 *cpu, uint16_t* dest, uint16_t value, uint8_t ins) {
  if (!dest) {
    return;
  }
  uint32_t result = 0;
  switch (ins) {
    case ALU_OP_ADD:
      result = *dest + value;
      break;
    case ALU_OP_ADC:
      result = *dest + value + getFlag(cpu, FLAG_C);
      break;
    case ALU_OP_SUB:
      result = *dest - value;
      break;
    case ALU_OP_SBC:
      result = *dest - value - getFlag(cpu, FLAG_C);
      break;
    case ALU_OP_INC:
      result = *dest + 1;
      return;
    case ALU_OP_DEC:
      result = *dest - 1;
      return;

    default:
      return;
  }

  updateFlags16(cpu, result);
  *dest = result;
}

void MainInstruction(VirtZ80 *cpu) {
  uint8_t opcode = fByte(cpu);
  uint16_t addr = 0;
  uint8_t temp1 = 0;
  switch (opcode) {
    case 0x00: // NOP
      cpu->cycles += 4;
      break;
    case 0x01: // LD BC, nn
      cpu->bc = fWord(cpu);
      cpu->cycles += 10;
      break;
    case 0x02: // LD (BC), A
      cpu->memory[cpu->bc] = getHigh(cpu->af);
      cpu->cycles += 7;
      break;
    case 0x03: // INC BC
      cpu->bc++;
      cpu->cycles += 6;
      break;
    case 0x04: // INC B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_INC);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 4;
      break;
    case 0x05: // DEC B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 4;
      break;
    case 0x06: // LD B, n
      loadHigh(&cpu->bc, fByte(cpu));
      cpu->cycles += 7;
    case 0x07: // RLCA
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_RLC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x08: // EX AF, AF'
      exchange(&cpu->af, &cpu->afa);
      cpu->cycles += 4;
      break;
    case 0x09: // ADD HL, BC
      alu16(cpu, &cpu->hl, cpu->bc, ALU_OP_ADD);
      cpu->cycles += 11;
      break;
    case 0x0A: // LD A, (BC)
      temp1 = cpu->memory[cpu->bc];
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0x0B: // DEC BC
      cpu->bc--;
      cpu->cycles += 6;
      break;
    case 0x0C: // INC C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_INC);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 4;
      break;
    case 0x0D: // DEC C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 4;
      break;
    case 0x0E: // LD C, n
      loadLow(&cpu->bc, fByte(cpu));
      cpu->cycles += 7;
      break;
    case 0x0F: // RRCA
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_RRC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x10: // DJNZ d
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadHigh(&cpu->bc, temp1);
      if (temp1 != 0) {
        cpu->pc += (int8_t)fByte(cpu);
        cpu->cycles += 13;
        break;
      }
      cpu->cycles += 8;
      break;
    case 0x11: // LD DE, nn
      cpu->de = fWord(cpu);
      cpu->cycles += 10;
      break;
    case 0x12: // LD (DE), A
      cpu->memory[cpu->de] = getHigh(cpu->af);
      cpu->cycles += 7;
      break;
    case 0x13: // INC DE
      cpu->de++;
      cpu->cycles += 6;
      break;
    case 0x14: // INC D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_INC);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 4;
      break;
    case 0x15: // DEC D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 4;
      break;
    case 0x16: // LD D, n
      loadHigh(&cpu->de, fByte(cpu));
      cpu->cycles += 7;
      break;
    case 0x17: // RLA
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_RL);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x18: // JR d
      cpu->pc += (int8_t)fByte(cpu);
      cpu->cycles += 12;
      break;
    case 0x19: // ADD HL, DE
      alu16(cpu, &cpu->hl, cpu->de, ALU_OP_ADD);
      cpu->cycles += 11;
      break;
    case 0x1A: // LD A, (DE)
      temp1 = cpu->memory[cpu->de];
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0x1B: // DEC DE
      cpu->de--;
      cpu->cycles += 6;
      break;
    case 0x1C: // INC E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_INC);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 4;
      break;
    case 0x1D: // DEC E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 4;
      break;
    case 0x1E: // LD E, n
      loadLow(&cpu->de, fByte(cpu));
      cpu->cycles += 7;
      break;
    case 0x1F: // RRA
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_RR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x20: // JR NZ, d
      temp1 = fByte(cpu);
      if (getFlag(cpu, FLAG_Z) == 0) {
        cpu->pc += (int8_t)temp1;
        cpu->cycles += 12;
        break;
      }
      cpu->cycles += 7;
      break;
    case 0x21: // LD HL, nn
      cpu->hl = fWord(cpu);
      cpu->cycles += 10;
      break;
    case 0x22: // LD (nn), HL
      addr = fWord(cpu);
      cpu->memory[addr] = getLow(cpu->hl);
      cpu->memory[addr + 1] = getHigh(cpu->hl);
      cpu->cycles += 16;
      break;
    case 0x23: // INC HL
      cpu->hl++;
      cpu->cycles += 6;
      break;
    case 0x24: // INC H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_INC);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 4;
      break;
    case 0x25: // DEC H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 4;
      break;
    case 0x26: // LD H, n
      loadHigh(&cpu->hl, fByte(cpu));
      cpu->cycles += 7;
      break;
    case 0x27: // DAA
      // TODO
      cpu->cycles += 4;
      break;
    case 0x28: // JR Z, d
      temp1 = fByte(cpu);
      if (getFlag(cpu, FLAG_Z) == 1) {
        cpu->pc += (int8_t)temp1;
        cpu->cycles += 12;
        break;
      }
      cpu->cycles += 7;
      break;
    case 0x29: // ADD HL, HL
      alu16(cpu, &cpu->hl, cpu->hl, ALU_OP_ADD);
      cpu->cycles += 11;
      break;
    case 0x2A: // LD HL, (nn)
      addr = fWord(cpu);
      loadLow(&cpu->hl, cpu->memory[addr]);
      loadHigh(&cpu->hl, cpu->memory[addr + 1]);
      cpu->cycles += 16;
      break;
    case 0x2B: // DEC HL
      cpu->hl--;
      cpu->cycles += 6;
      break;
    case 0x2C: // INC L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_INC);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 4;
      break;
    case 0x2D: // DEC L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 4;
      break;
    case 0x2E: // LD L, n
      loadLow(&cpu->hl, fByte(cpu));
      cpu->cycles += 7;
      break;
    case 0x2F: // CPL
      temp1 = getHigh(cpu->af);
      temp1 = ~temp1;
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x30: // JR NC, d
      temp1 = fByte(cpu);
      if (getFlag(cpu, FLAG_C) == 0) {
        cpu->pc += (int8_t)temp1;
        cpu->cycles += 12;
        break;
      }
      cpu->cycles += 7;
      break;
    case 0x31: // LD SP, nn
      cpu->sp = fWord(cpu);
      cpu->cycles += 10;
      break;
    case 0x32: // LD (nn), A
      addr = fWord(cpu);
      cpu->memory[addr] = getLow(cpu->af);
      cpu->cycles += 13;
      break;
    case 0x33: // INC SP
      cpu->sp++;
      cpu->cycles += 6;
      break;
    case 0x34: // INC (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_INC);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 11;
      break;
    case 0x35: // DEC (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 11;
      break;
    case 0x36: // LD (HL), n
      cpu->memory[cpu->hl] = fByte(cpu);
      cpu->cycles += 10;
      break;
    case 0x37: // SCF
      cpu->af = cpu->af | FLAG_C;
      cpu->cycles += 4;
      break;
    case 0x38: // JR C, d
      temp1 = fByte(cpu);
      if (getFlag(cpu, FLAG_C) == 1) {
        cpu->pc += (int8_t)temp1;
        cpu->cycles += 12;
        break;
      }
      cpu->cycles += 7;
      break;
    case 0x39: // ADD HL, SP
      alu16(cpu, &cpu->hl, cpu->sp, ALU_OP_ADD);
      cpu->cycles += 11;
      break;
    case 0x3A: // LD A, (nn)
      addr = fWord(cpu);
      loadLow(&cpu->af, cpu->memory[addr]);
      cpu->cycles += 13;
      break;
    case 0x3B: // DEC SP
      cpu->sp--;
      cpu->cycles += 6;
      break;
    case 0x3C: // INC A
      temp1 = getLow(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_INC);
      loadLow(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x3D: // DEC A
      temp1 = getLow(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadLow(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x3E: // LD A, n
      loadLow(&cpu->af, fByte(cpu));
      cpu->cycles += 7;
      break;
    case 0x3F: // CCF
      cpu->af = cpu->af ^ FLAG_C;
      cpu->cycles += 4;
      break;
    case 0x40: // LD B, B
      cpu->cycles += 4;
      break;
    case 0x41: // LD B, C
      loadHigh(&cpu->bc, getLow(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x42: // LD B, D
      loadHigh(&cpu->bc, getHigh(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x43: // LD B, E
      loadHigh(&cpu->bc, getLow(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x44: // LD B, H
      loadHigh(&cpu->bc, getHigh(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x45: // LD B, L
      loadHigh(&cpu->bc, getLow(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x46: // LD B, (HL)
      loadHigh(&cpu->bc, cpu->memory[cpu->hl]);
      cpu->cycles += 7;
      break;
    case 0x47: // LD B, A
      loadHigh(&cpu->bc, getHigh(cpu->af));
      cpu->cycles += 4;
      break;
    case 0x48: // LD C, B
      loadLow(&cpu->bc, getHigh(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x49: // LD C, C
      cpu->cycles += 4;
      break;
    case 0x4A: // LD C, D
      loadLow(&cpu->bc, getHigh(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x4B: // LD C, E
      loadLow(&cpu->bc, getLow(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x4C: // LD C, H
      loadLow(&cpu->bc, getHigh(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x4D: // LD C, L
      loadLow(&cpu->bc, getLow(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x4E: // LD C, (HL)
      loadLow(&cpu->bc, cpu->memory[cpu->hl]);
      cpu->cycles += 7;
      break;
    case 0x4F: // LD C, A
      loadLow(&cpu->bc, getHigh(cpu->af));
      cpu->cycles += 4;
      break;
    case 0x50: // LD D, B
      loadHigh(&cpu->de, getHigh(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x51: // LD D, C
      loadHigh(&cpu->de, getLow(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x52: // LD D, D
      cpu->cycles += 4;
      break;
    case 0x53: // LD D, E
      loadHigh(&cpu->de, getLow(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x54: // LD D, H
      loadHigh(&cpu->de, getHigh(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x55: // LD D, L
      loadHigh(&cpu->de, getLow(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x56: // LD D, (HL)
      loadHigh(&cpu->de, cpu->memory[cpu->hl]);
      cpu->cycles += 7;
      break;
    case 0x57: // LD D, A
      loadHigh(&cpu->de, getHigh(cpu->af));
      cpu->cycles += 4;
      break;
    case 0x58: // LD E, B
      loadLow(&cpu->de, getHigh(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x59: // LD E, C
      loadLow(&cpu->de, getLow(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x5A: // LD E, D
      loadLow(&cpu->de, getHigh(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x5B: // LD E, E
      cpu->cycles += 4;
      break;
    case 0x5C: // LD E, H
      loadLow(&cpu->de, getHigh(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x5D: // LD E, L
      loadLow(&cpu->de, getLow(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x5E: // LD E, (HL)
      loadLow(&cpu->de, cpu->memory[cpu->hl]);
      cpu->cycles += 7;
      break;
    case 0x5F: // LD E, A
      loadLow(&cpu->de, getHigh(cpu->af));
      cpu->cycles += 4;
      break;
    case 0x60: // LD H, B
      loadHigh(&cpu->hl, getHigh(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x61: // LD H, C
      loadHigh(&cpu->hl, getLow(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x62: // LD H, D
      loadHigh(&cpu->hl, getHigh(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x63: // LD H, E
      loadHigh(&cpu->hl, getLow(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x64: // LD H, H
      cpu->cycles += 4;
      break;
    case 0x65: // LD H, L
      loadHigh(&cpu->hl, getLow(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x66: // LD H, (HL)
      temp1 = cpu->hl;
      loadHigh(&cpu->hl, cpu->memory[cpu->hl]);
      cpu->cycles += 7;
      break;
    case 0x67: // LD H, A
      loadHigh(&cpu->hl, getHigh(cpu->af));
      cpu->cycles += 4;
      break;
    case 0x68: // LD L, B
      loadLow(&cpu->hl, getHigh(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x69: // LD L, C
      loadLow(&cpu->hl, getLow(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x6A: // LD L, D
      loadLow(&cpu->hl, getHigh(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x6B: // LD L, E
      loadLow(&cpu->hl, getLow(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x6C: // LD L, H
      loadLow(&cpu->hl, getHigh(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x6D: // LD L, L
      cpu->cycles += 4;
      break;
    case 0x6E: // LD L, (HL)
      temp1 = cpu->hl;
      loadLow(&cpu->hl, cpu->memory[temp1]);
      cpu->cycles += 7;
      break;
    case 0x6F: // LD L, A
      loadLow(&cpu->hl, getHigh(cpu->af));
      cpu->cycles += 4;
      break;
    case 0x70: // LD (HL), B
      cpu->memory[cpu->hl] = getHigh(cpu->bc);
      cpu->cycles += 7;
      break;
    case 0x71: // LD (HL), C
      cpu->memory[cpu->hl] = getLow(cpu->bc);
      cpu->cycles += 7;
      break;
    case 0x72: // LD (HL), D
      cpu->memory[cpu->hl] = getHigh(cpu->de);
      cpu->cycles += 7;
      break;
    case 0x73: // LD (HL), E
      cpu->memory[cpu->hl] = getLow(cpu->de);
      cpu->cycles += 7;
      break;
    case 0x74: // LD (HL), H
      cpu->memory[cpu->hl] = getHigh(cpu->hl);
      cpu->cycles += 7;
      break;
    case 0x75: // LD (HL), L
      cpu->memory[cpu->hl] = getLow(cpu->hl);
      cpu->cycles += 7;
      break;
    case 0x76: // HALT
      cpu->halt = true;
      cpu->cycles += 4;
      break;
    case 0x77: // LD (HL), A
      cpu->memory[cpu->hl] = getHigh(cpu->af);
      cpu->cycles += 7;
      break;
    case 0x78: // LD A, B
      loadHigh(&cpu->af, getHigh(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x79: // LD A, C
      loadHigh(&cpu->af, getLow(cpu->bc));
      cpu->cycles += 4;
      break;
    case 0x7A: // LD A, D
      loadHigh(&cpu->af, getHigh(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x7B: // LD A, E
      loadHigh(&cpu->af, getLow(cpu->de));
      cpu->cycles += 4;
      break;
    case 0x7C: // LD A, H
      loadHigh(&cpu->af, getHigh(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x7D: // LD A, L
      loadHigh(&cpu->af, getLow(cpu->hl));
      cpu->cycles += 4;
      break;
    case 0x7E: // LD A, (HL)
      loadHigh(&cpu->af, cpu->memory[cpu->hl]);
      cpu->cycles += 7;
      break;
    case 0x7F: // LD A, A
      cpu->cycles += 4;
      break;
    case 0x80: // ADD A, B
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->bc), ALU_OP_ADD);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x81: // ADD A, C
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->bc), ALU_OP_ADD);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x82: // ADD A, D
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->de), ALU_OP_ADD);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x83: // ADD A, E
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->de), ALU_OP_ADD);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x84: // ADD A, H
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->hl), ALU_OP_ADD);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x85: // ADD A, L
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->hl), ALU_OP_ADD);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x86: // ADD A, (HL)
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_ADD);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0x87: // ADD A, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->af), ALU_OP_ADD);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x88: // ADC A, B
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->bc), ALU_OP_ADC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x89: // ADC A, C
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->bc), ALU_OP_ADC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x8A: // ADC A, D
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->de), ALU_OP_ADC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x8B: // ADC A, E
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->de), ALU_OP_ADC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x8C: // ADC A, H
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->hl), ALU_OP_ADC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x8D: // ADC A, L
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->hl), ALU_OP_ADC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x8E: // ADC A, (HL)
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_ADC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0x8F: // ADC A, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->af), ALU_OP_ADC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x90: // SUB B
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->bc), ALU_OP_SUB);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x91: // SUB C
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->bc), ALU_OP_SUB);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x92: // SUB D
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->de), ALU_OP_SUB);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x93: // SUB E
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->de), ALU_OP_SUB);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x94: // SUB H
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->hl), ALU_OP_SUB);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x95: // SUB L
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->hl), ALU_OP_SUB);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x96: // SUB (HL)
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_SUB);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0x97: // SUB A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->af), ALU_OP_SUB);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x98: // SBC A, B
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->bc), ALU_OP_SBC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x99: // SBC A, C
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->bc), ALU_OP_SBC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x9A: // SBC A, D
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->de), ALU_OP_SBC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x9B: // SBC A, E
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->de), ALU_OP_SBC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x9C: // SBC A, H
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->hl), ALU_OP_SBC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x9D: // SBC A, L
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->hl), ALU_OP_SBC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0x9E: // SBC A, (HL)
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_SBC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0x9F: // SBC A, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->af), ALU_OP_SBC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xA0: // AND B
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->bc), ALU_OP_AND);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xA1: // AND C
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->bc), ALU_OP_AND);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xA2: // AND D
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->de), ALU_OP_AND);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xA3: // AND E
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->de), ALU_OP_AND);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xA4: // AND H
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->hl), ALU_OP_AND);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xA5: // AND L
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->hl), ALU_OP_AND);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xA6: // AND (HL)
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_AND);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0xA7: // AND A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->af), ALU_OP_AND);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xA8: // XOR B
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->bc), ALU_OP_XOR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xA9: // XOR C
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->bc), ALU_OP_XOR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xAA: // XOR D
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->de), ALU_OP_XOR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xAB: // XOR E
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->de), ALU_OP_XOR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xAC: // XOR H
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->hl), ALU_OP_XOR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xAD: // XOR L
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->hl), ALU_OP_XOR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xAE: // XOR (HL)
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_XOR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0xAF: // XOR A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->af), ALU_OP_XOR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xB0: // OR B
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->bc), ALU_OP_OR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xB1: // OR C
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->bc), ALU_OP_OR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xB2: // OR D
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->de), ALU_OP_OR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xB3: // OR E
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->de), ALU_OP_OR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xB4: // OR H
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->hl), ALU_OP_OR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xB5: // OR L
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->hl), ALU_OP_OR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xB6: // OR (HL)
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_OR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0xB7: // OR A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->af), ALU_OP_OR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 4;
      break;
    case 0xB8: // CP B
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->bc), ALU_OP_CP);
      cpu->cycles += 4;
      break;
    case 0xB9: // CP C
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->bc), ALU_OP_CP);
      cpu->cycles += 4;
      break;
    case 0xBA: // CP D
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->de), ALU_OP_CP);
      cpu->cycles += 4;
      break;
    case 0xBB: // CP E
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->de), ALU_OP_CP);
      cpu->cycles += 4;
      break;
    case 0xBC: // CP H
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->hl), ALU_OP_CP);
      cpu->cycles += 4;
      break;
    case 0xBD: // CP L
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getLow(cpu->hl), ALU_OP_CP);
      cpu->cycles += 4;
      break;
    case 0xBE: // CP (HL)
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_CP);
      cpu->cycles += 7;
      break;
    case 0xBF: // CP A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, getHigh(cpu->af), ALU_OP_CP);
      cpu->cycles += 4;
      break;
    case 0xC0: // RET NZ
      if (getFlag(cpu, FLAG_Z) == 0) {
        cpu->pc = pop(cpu);
        cpu->cycles += 11;
        break;
      }
      cpu->cycles += 5;
      break;
    case 0xC1: // POP BC
      cpu->bc = pop(cpu);
      cpu->cycles += 10;
      break;
    case 0xC2: // JP NZ, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_Z) == 0) {
        cpu->pc = cpu->wz;
      }
      cpu->cycles += 10;
      break;
    case 0xC3: // JP nn
      cpu->wz = fWord(cpu);
      cpu->pc = cpu->wz;
      cpu->cycles += 10;
      break;
    case 0xC4: // CALL NZ, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_Z) == 0) {
        push(cpu, cpu->pc);
        cpu->pc = cpu->wz;
        cpu->cycles += 7;
      }
      cpu->cycles += 10;
      break;
    case 0xC5: // PUSH BC
      push(cpu, cpu->bc);
      cpu->cycles += 11;
      break;
    case 0xC6: // ADD A, n
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, fByte(cpu), ALU_OP_ADD);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0xC7: // RST 0
      push(cpu, cpu->pc);
      cpu->pc = 0x00;
      cpu->cycles += 11;
      break;
    case 0xC8: // RET Z
      if (getFlag(cpu, FLAG_Z) != 0) {
        cpu->pc = pop(cpu);
        cpu->cycles += 11;
        break;
      }
      cpu->cycles += 5;
      break;
    case 0xC9: // RET
      cpu->pc = pop(cpu);
      cpu->cycles += 10;
      break;
    case 0xCA: // JP Z, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_Z) != 0) {
        cpu->pc = cpu->wz;
      }
      cpu->cycles += 10;
      break;
    case 0xCB: // Bit instruction
      BitInstruction(cpu);
      break;
    case 0xCC: // CALL Z, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_Z) == 1) {
        push(cpu, cpu->pc);
        cpu->pc = cpu->wz;
        cpu->cycles += 7;
      }
      cpu->cycles += 10;
      break;
    case 0xCD: // CALL nn
      cpu->wz = fWord(cpu);
      push(cpu, cpu->pc);
      cpu->pc = cpu->wz;
      cpu->cycles += 17;
      break;
    case 0xCE: // ADC A, n
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, fByte(cpu), ALU_OP_ADC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0xCF: // RST 8
      push(cpu, cpu->pc);
      cpu->pc = 0x08;
      cpu->cycles += 11;
      break;
    case 0xD0: // RET NC
      if (getFlag(cpu, FLAG_C) == 0) {
        cpu->pc = pop(cpu);
        cpu->cycles += 11;
        break;
      }
      cpu->cycles += 5;
      break;
    case 0xD1: // POP DE
      cpu->de = pop(cpu);
      cpu->cycles += 10;
      break;
    case 0xD2: // JP NC, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_C) == 0) {
        cpu->pc = cpu->wz;
      }
      cpu->cycles += 10;
      break;
    case 0xD3: // OUT (n), A
      temp1 = getHigh(cpu->af);
      OutputHandler(fByte(cpu), temp1);
      cpu->cycles += 11;
      break;
    case 0xD4: // CALL NC, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_C) == 0) {
        push(cpu, cpu->pc);
        cpu->pc = cpu->wz;
        cpu->cycles += 7;
      }
      cpu->cycles += 10;
      break;
    case 0xD5: // PUSH DE
      push(cpu, cpu->de);
      cpu->cycles += 11;
      break;
    case 0xD6: // SUB A, n
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, fByte(cpu), ALU_OP_SUB);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0xD7: // RST 10
      push(cpu, cpu->pc);
      cpu->pc = 0x10;
      cpu->cycles += 11;
      break;
    case 0xD8: // RET C
      if (getFlag(cpu, FLAG_C) != 0) {
        cpu->pc = pop(cpu);
        cpu->cycles += 11;
        break;
      }
      cpu->cycles += 5;
      break;
    case 0xD9: // EXX
      exchange(&cpu->bc, &cpu->bca);
      exchange(&cpu->de, &cpu->dea);
      exchange(&cpu->hl, &cpu->hla);
      cpu->cycles += 4;
      break;
    case 0xDA: // JP C, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_C) != 0) {
        cpu->pc = cpu->wz;
      }
      cpu->cycles += 10;
      break;
    case 0xDB: // IN A, (n)
      temp1 = getHigh(cpu->af);
      temp1 = InputHandler(fByte(cpu));
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 11;
      break;
    case 0xDC: // CALL C, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_C) != 0) {
        push(cpu, cpu->pc);
        cpu->pc = cpu->wz;
        cpu->cycles += 7;
      }
      cpu->cycles += 10;
      break;
    case 0xDD: // IX Prefix
      break;
    case 0xDE: // SBC A, n
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, fByte(cpu), ALU_OP_SBC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0xDF: // RST 18
      push(cpu, cpu->pc);
      cpu->pc = 0x18;
      cpu->cycles += 11;
      break;
    case 0xE0: // RET PO
      if (getFlag(cpu, FLAG_P) == 0) {
        cpu->pc = pop(cpu);
        cpu->cycles += 11;
        break;
      }
      cpu->cycles += 5;
      break;
    case 0xE1: // POP HL
      cpu->hl = pop(cpu);
      cpu->cycles += 10;
      break;
    case 0xE2: // JP PO, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_P) == 0) {
        cpu->pc = cpu->wz;
      }
      cpu->cycles += 10;
      break;
    case 0xE3: // EX (SP),HL
      temp1 = cpu->memory[cpu->sp];
      cpu->memory[cpu->sp] = getLow(cpu->hl);
      loadLow(&cpu->hl, temp1);
      temp1 = cpu->memory[cpu->sp + 1];
      cpu->memory[cpu->sp + 1] = getHigh(cpu->hl);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 19;
      break;
    case 0xE4: // CALL PO, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_P) == 0) {
        push(cpu, cpu->pc);
        cpu->pc = cpu->wz;
        cpu->cycles += 7;
      }
      cpu->cycles += 10;
      break;
    case 0xE5: // PUSH HL
      push(cpu, cpu->hl);
      cpu->cycles += 11;
      break;
    case 0xE6: // AND A, n
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, fByte(cpu), ALU_OP_AND);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0xE7: // RST 20
      push(cpu, cpu->pc);
      cpu->pc = 0x20;
      cpu->cycles += 11;
      break;
    case 0xE8: // RET PE
      if (getFlag(cpu, FLAG_P) != 0) {
        cpu->pc = pop(cpu);
        cpu->cycles += 11;
        break;
      }
      cpu->cycles += 5;
      break;
    case 0xE9: // JP (HL)
      cpu->pc = cpu->hl;
      cpu->cycles += 4;
      break;
    case 0xEA: // JP PE, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_P) != 0) {
        cpu->pc = cpu->wz;
      }
      cpu->cycles += 10;
      break;
    case 0xEB: // EX DE,HL
      exchange(&cpu->de, &cpu->hl);
      cpu->cycles += 4;
      break;
    case 0xEC: // CALL PE, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_P) != 0) {
        push(cpu, cpu->pc);
        cpu->pc = cpu->wz;
        cpu->cycles += 7;
      }
      cpu->cycles += 10;
      break;
    case 0xED: // Misc. Instructions
      MiscInstruction(cpu);
      break;
    case 0xEE: // XOR A, n
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, fByte(cpu), ALU_OP_XOR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0xEF: // RST 28
      push(cpu, cpu->pc);
      cpu->pc = 0x28;
      cpu->cycles += 11;
      break;
    case 0xF0: // RET P
      if (getFlag(cpu, FLAG_P) == 0) {
        cpu->pc = pop(cpu);
        cpu->cycles += 11;
        break;
      }
      cpu->cycles += 5;
      break;
    case 0xF1: // POP AF
      cpu->af = pop(cpu);
      cpu->cycles += 10;
      break;
    case 0xF2: // JP P, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_P) == 0) {
        cpu->pc = cpu->wz;
      }
      cpu->cycles += 10;
      break;
    case 0xF3: // DI
      cpu->im = 0;
      cpu->cycles += 4;
      break;
    case 0xF4: // CALL P, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_P) == 0) {
        push(cpu, cpu->pc);
        cpu->pc = cpu->wz;
        cpu->cycles += 7;
      }
      cpu->cycles += 10;
      break;
    case 0xF5: // PUSH AF
      push(cpu, cpu->af);
      cpu->cycles += 11;
      break;
    case 0xF6: // OR A, n
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, fByte(cpu), ALU_OP_OR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 7;
      break;
    case 0xF7: // RST 30
      push(cpu, cpu->pc);
      cpu->pc = 0x30;
      cpu->cycles += 11;
      break;
    case 0xF8: // RET M
      if (getFlag(cpu, FLAG_S) != 0) {
        cpu->pc = pop(cpu);
        cpu->cycles += 11;
        break;
      }
      cpu->cycles += 5;
      break;
    case 0xF9: // LD SP, HL
      cpu->sp = cpu->hl;
      cpu->cycles += 6;
      break;
    case 0xFA: // JP M, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_S) != 0) {
        cpu->pc = cpu->wz;
      }
      cpu->cycles += 10;
      break;
    case 0xFB: // EI
      cpu->im = 1;
      cpu->cycles += 4;
      break;
    case 0xFC: // CALL M, nn
      cpu->wz = fWord(cpu);
      if (getFlag(cpu, FLAG_S) != 0) {
        push(cpu, cpu->pc);
        cpu->pc = cpu->wz;
        cpu->cycles += 7;
      }
      cpu->cycles += 10;
      break;
    case 0xFD: // IY Prefix
      break;
    case 0xFE: // CP A, n
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, fByte(cpu), ALU_OP_CP);
      cpu->cycles += 7;
      break;
    case 0xFF: // RST 38
      push(cpu, cpu->pc);
      cpu->pc = 0x38;
      cpu->cycles += 11;
      break;
    default:
      cpu->cycles += 4;
      break;
  }
}

void MiscInstruction(VirtZ80 *cpu) {
  uint8_t opcode = fByte(cpu);
  uint8_t temp1 = 0;
  uint16_t addr = 0;
  switch (opcode) {
    case 0x40: // IN B, (C)
      loadHigh(&cpu->bc, InputHandler(getLow(cpu->bc)));
      cpu->cycles += 12;
      break;
    case 0x41: // OUT (C), B
      OutputHandler(getLow(cpu->bc), getHigh(cpu->bc));
      cpu->cycles += 12;
      break;
    case 0x42: // SBC HL, BC
      alu16(cpu, &cpu->hl, cpu->bc, ALU_OP_SBC);
      cpu->cycles += 15;
      break;
    case 0x43: // LD (nn), BC
      addr = fWord(cpu);
      cpu->memory[addr] = getLow(cpu->bc);
      cpu->memory[addr + 1] = getHigh(cpu->bc);
      cpu->cycles += 20;
      break;
    case 0x44: // NEG
      temp1 = 0;
      alu8(cpu, &temp1, getHigh(cpu->af), ALU_OP_SUB);
      loadLow(&cpu->af, temp1);
      cpu->cycles += 8;
      break;
    case 0x45: // RETN
      cpu->pc = pop(cpu);
      cpu->iff1 = cpu->iff2;
      cpu->cycles += 14;
      break;
    case 0x46: // IM 0
      cpu->im = 0;
      cpu->cycles += 8;
      break;
    case 0x47: // LD I, A
      cpu->i = getLow(cpu->af);
      cpu->cycles += 9;
      break;
    case 0x48: // IN C, (C)
      loadHigh(&cpu->bc, InputHandler(getLow(cpu->bc)));
      cpu->cycles += 12;
      break;
    case 0x49: // OUT (C), C
      OutputHandler(getLow(cpu->bc), getHigh(cpu->bc));
      cpu->cycles += 12;
      break;
    case 0x4A: // ADC HL, BC
      alu16(cpu, &cpu->hl, cpu->bc, ALU_OP_ADC);
      cpu->cycles += 15;
      break;
    case 0x4B: // LD BC, (nn)
      addr = fWord(cpu);
      cpu->bc = cpu->memory[addr];
      cpu->bc |= cpu->memory[addr + 1] << 8;
      cpu->cycles += 20;
      break;
    case 0x4D: // RETI
      cpu->pc = pop(cpu);
      cpu->iff1 = 1;
      cpu->iff2 = 1;
      cpu->cycles += 14;
      break;
    case 0x4F: // LD R, A
      cpu->r = getLow(cpu->af);
      cpu->cycles += 9;
      break;
    case 0x50: // IN D, (C)
      loadHigh(&cpu->de, InputHandler(getLow(cpu->de)));
      cpu->cycles += 12;
      break;
    case 0x51: // OUT (C), D
      OutputHandler(getLow(cpu->de), getHigh(cpu->de));
      cpu->cycles += 12;
      break;
    case 0x52: // SBC HL, DE
      alu16(cpu, &cpu->hl, cpu->de, ALU_OP_SBC);
      cpu->cycles += 15;
      break;
    case 0x53: // LD (nn), DE
      addr = fWord(cpu);
      cpu->memory[addr] = getLow(cpu->de);
      cpu->memory[addr + 1] = getHigh(cpu->de);
      cpu->cycles += 20;
      break;
    case 0x56: // IM 1
      cpu->im = 1;
      cpu->cycles += 8;
      break;
    case 0x57: // LD A, I
      loadLow(&cpu->af, cpu->i);
      cpu->cycles += 9;
      break;
    case 0x58: // IN E, (C)
      loadHigh(&cpu->de, InputHandler(getLow(cpu->de)));
      cpu->cycles += 12;
      break;
    case 0x59: // OUT (C), E
      OutputHandler(getLow(cpu->de), getHigh(cpu->de));
      cpu->cycles += 12;
      break;
    case 0x5A: // ADC HL, DE
      alu16(cpu, &cpu->hl, cpu->de, ALU_OP_ADC);
      cpu->cycles += 15;
      break;
    case 0x5B: // LD DE, (nn)
      addr = fWord(cpu);
      cpu->de = cpu->memory[addr];
      cpu->de |= cpu->memory[addr + 1] << 8;
      cpu->cycles += 20;
      break;
    case 0x5E: // IM 2
      cpu->im = 2;
      cpu->cycles += 8;
      break;
    case 0x5F: // LD A, R
      loadLow(&cpu->af, cpu->r);
      cpu->cycles += 9;
      break;
    case 0x60: // IN H, (C)
      loadHigh(&cpu->hl, InputHandler(getLow(cpu->hl)));
      cpu->cycles += 12;
      break;
    case 0x61: // OUT (C), H
      OutputHandler(getLow(cpu->hl), getHigh(cpu->hl));
      cpu->cycles += 12;
      break;
    case 0x62: // SBC HL, HL
      alu16(cpu, &cpu->hl, cpu->hl, ALU_OP_SBC);
      cpu->cycles += 15;
      break;
    case 0x63: // LD (nn), HL
      addr = fWord(cpu);
      cpu->memory[addr] = getLow(cpu->hl);
      cpu->memory[addr + 1] = getHigh(cpu->hl);
      cpu->cycles += 20;
      break;
    case 0x66: // IM 0
      cpu->im = 0;
      cpu->cycles += 8;
      break;
    case 0x67: // RRD
      cpu->memory[cpu->hl] = (cpu->memory[cpu->hl] >> 4) | (cpu->memory[cpu->hl] << 4);
      cpu->cycles += 18;
      break;
    case 0x68: // IN L, (C)
      loadHigh(&cpu->hl, InputHandler(getLow(cpu->hl)));
      cpu->cycles += 12;
      break;
    case 0x69: // OUT (C), L
      OutputHandler(getLow(cpu->hl), getHigh(cpu->hl));
      cpu->cycles += 12;
      break;
    case 0x6A: // ADC HL, HL
      alu16(cpu, &cpu->hl, cpu->hl, ALU_OP_ADC);
      cpu->cycles += 15;
      break;
    case 0x6B: // LD HL, (nn)
      addr = fWord(cpu);
      cpu->hl = cpu->memory[addr];
      cpu->hl |= cpu->memory[addr + 1] << 8;
      cpu->cycles += 20;
      break;
    case 0x6F: // RLD
      cpu->memory[cpu->hl] = (cpu->memory[cpu->hl] << 4) | (cpu->memory[cpu->hl] >> 4);
      cpu->cycles += 18;
      break;
    case 0x70: // IN (C)
      InputHandler(getLow(cpu->hl));
      cpu->cycles += 12;
      break;
    case 0x71: // OUT (C), 0
      OutputHandler(getLow(cpu->hl), 0);
      cpu->cycles += 12;
      break;
    case 0x72: // SBC HL, SP
      alu16(cpu, &cpu->hl, cpu->sp, ALU_OP_SBC);
      cpu->cycles += 15;
      break;
    case 0x73: // LD (nn), SP
      addr = fWord(cpu);
      cpu->memory[addr] = getLow(cpu->sp);
      cpu->memory[addr + 1] = getHigh(cpu->sp);
      cpu->cycles += 20;
      break;
    case 0x78: // IN A, (C)
      loadHigh(&cpu->af, InputHandler(getLow(cpu->af)));
      cpu->cycles += 12;
      break;
    case 0x79: // OUT (C), A
      OutputHandler(getLow(cpu->af), getHigh(cpu->af));
      cpu->cycles += 12;
      break;
    case 0x7A: // ADC HL, SP
      alu16(cpu, &cpu->hl, cpu->sp, ALU_OP_ADC);
      cpu->cycles += 15;
      break;
    case 0x7B: // LD SP, (nn)
      addr = fWord(cpu);
      cpu->sp = cpu->memory[addr];
      cpu->sp |= cpu->memory[addr + 1] << 8;
      cpu->cycles += 20;
      break;
    case 0xA0: // LDI
      cpu->memory[cpu->de] = cpu->memory[cpu->hl];
      cpu->hl++;
      cpu->de++;
      cpu->bc--;
      if (cpu->bc == 0) {
        cpu->af |= FLAG_P;
      } else cpu->af &= ~FLAG_P;
      cpu->cycles += 16;
      break;
    case 0xA1: // CPI
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_CP);
      cpu->hl++;
      cpu->bc--;
      if (cpu->bc == 0) {
        cpu->af |= FLAG_P;
      } else cpu->af &= ~FLAG_P;
      cpu->cycles += 16;
      break;
    case 0xA2: // INI
      cpu->memory[cpu->hl] = InputHandler(getLow(cpu->c));
      cpu->hl++;
      cpu->bc--;
      if (cpu->bc == 0) {
        cpu->af |= FLAG_P;
      } else cpu->af &= ~FLAG_P;
      cpu->cycles += 16;
      break;
    case 0xA3: // OUTI
      OutputHandler(getLow(cpu->c), cpu->memory[cpu->hl]);
      cpu->hl++;
      cpu->bc--;
      if (cpu->bc == 0) {
        cpu->af |= FLAG_P;
      } else cpu->af &= ~FLAG_P;
      cpu->cycles += 16;
      break;
    case 0xA8: // LDD
      cpu->memory[cpu->de] = cpu->memory[cpu->hl];
      cpu->hl--;
      cpu->de--;
      cpu->bc--;
      if (cpu->bc == 0) {
        cpu->af |= FLAG_P;
      } else cpu->af &= ~FLAG_P;
      cpu->cycles += 16;
      break;
    case 0xA9: // CPD
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_CP);
      cpu->hl--;
      cpu->bc--;
      if (cpu->bc == 0) {
        cpu->af |= FLAG_P;
      } else cpu->af &= ~FLAG_P;
      cpu->cycles += 16;
      break;
    case 0xAA: // IND
      cpu->memory[cpu->hl] = InputHandler(getLow(cpu->c));
      cpu->hl--;
      cpu->bc--;
      if (cpu->bc == 0) {
        cpu->af |= FLAG_P;
      } else cpu->af &= ~FLAG_P;
      cpu->cycles += 16;
      break;
    case 0xAB: // OUTD
      OutputHandler(getLow(cpu->c), cpu->memory[cpu->hl]);
      cpu->hl--;
      cpu->bc--;
      if (cpu->bc == 0) {
        cpu->af |= FLAG_P;
      } else cpu->af &= ~FLAG_P;
      cpu->cycles += 16;
      break;
    case 0xB0: // LDIR
      while (cpu->bc > 0) {
        cpu->memory[cpu->de] = cpu->memory[cpu->hl];
        cpu->hl++;
        cpu->de++;
        cpu->bc--;
        if (cpu->bc == 0) {
          cpu->af |= FLAG_P;
        } else cpu->af &= ~FLAG_P;
        cpu->cycles += 16;
      }
      break;
    case 0xB1: // CPIR
      temp1 = getHigh(cpu->af);
      while (cpu->bc > 0) {
        alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_CP);
        cpu->hl++;
        cpu->bc--;
        if (cpu->bc == 0) {
          cpu->af |= FLAG_P;
        } else cpu->af &= ~FLAG_P;
        cpu->cycles += 16;
      }
      break;
    case 0xB2: // INIR
      while (cpu->bc > 0) {
        cpu->memory[cpu->hl] = InputHandler(getLow(cpu->c));
        cpu->hl++;
        cpu->bc--;
        if (cpu->bc == 0) {
          cpu->af |= FLAG_P;
        } else cpu->af &= ~FLAG_P;
        cpu->cycles += 16;
      }
      break;
    case 0xB3: // OTIR
      while (cpu->bc > 0) {
        OutputHandler(getLow(cpu->c), cpu->memory[cpu->hl]);
        cpu->hl++;
        cpu->bc--;
        if (cpu->bc == 0) {
          cpu->af |= FLAG_P;
        } else cpu->af &= ~FLAG_P;
        cpu->cycles += 16;
      }
      break;
    case 0xB8: // LDDR
      while (cpu->bc > 0) {
        cpu->memory[cpu->de] = cpu->memory[cpu->hl];
        cpu->hl--;
        cpu->de--;
        cpu->bc--;
        if (cpu->bc == 0) {
          cpu->af |= FLAG_P;
        } else cpu->af &= ~FLAG_P;
        cpu->cycles += 16;
      }
      break;
    case 0xB9: // CPDR
      temp1 = getHigh(cpu->af);
      while (cpu->bc > 0) {
        alu8(cpu, &temp1, cpu->memory[cpu->hl], ALU_OP_CP);
        cpu->hl--;
        cpu->bc--;
        if (cpu->bc == 0) {
          cpu->af |= FLAG_P;
        } else cpu->af &= ~FLAG_P;
        cpu->cycles += 16;
      }
      break;
    case 0xBA: // INDR
      while (cpu->bc > 0) {
        cpu->memory[cpu->hl] = InputHandler(getLow(cpu->c));
        cpu->hl--;
        cpu->bc--;
        if (cpu->bc == 0) {
          cpu->af |= FLAG_P;
        } else cpu->af &= ~FLAG_P;
        cpu->cycles += 16;
      }
      break;
    case 0xBB: // OTDR
      while (cpu->bc > 0) {
        OutputHandler(getLow(cpu->c), cpu->memory[cpu->hl]);
        cpu->hl--;
        cpu->bc--;
        if (cpu->bc == 0) {
          cpu->af |= FLAG_P;
        } else cpu->af &= ~FLAG_P;
        cpu->cycles += 16;
      }
      break;
    default:
      cpu->cycles += 4;
      break;
  }
}

void BitInstruction(VirtZ80 *cpu) {
  uint8_t opcode = fByte(cpu);
  uint8_t temp1 = 0;
  switch (opcode) {
    case 0x00: // RLC B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_RLC);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x01: // RLC C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_RLC);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x02: // RLC D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_RLC);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x03: // RLC E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_RLC);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x04: // RLC H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_RLC);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x05: // RLC L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_RLC);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x06: // RLC (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_RLC);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 16;
      break;
    case 0x07: // RLC A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &cpu->temp1, 0, ALU_OP_RLC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;
    case 0x08: // RRC B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_RRC);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x09: // RRC C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_RRC);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x0A: // RRC D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_RRC);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x0B: // RRC E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_RRC);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x0C: // RRC H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_RRC);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x0D: // RRC L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_RRC);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x0E: // RRC (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_RRC);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 16;
      break;
    case 0x0F: // RRC A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &cpu->temp1, 0, ALU_OP_RRC);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;
    case 0x10: // RL B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_RL);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x11: // RL C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_RL);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x12: // RL D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_RL);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x13: // RL E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_RL);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x14: // RL H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_RL);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x15: // RL L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_RL);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x16: // RL (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_RL);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 16;
      break;
    case 0x17: // RL A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &cpu->temp1, 0, ALU_OP_RL);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;
    case 0x18: // RR B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_RR);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x19: // RR C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_RR);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x1A: // RR D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_RR);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x1B: // RR E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_RR);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x1C: // RR H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_RR);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x1D: // RR L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_RR);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x1E: // RR (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_RR);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 16;
      break;
    case 0x1F: // RR A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &cpu->temp1, 0, ALU_OP_RR);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0x20: // SLA B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_SLA);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x21: // SLA C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_SLA);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x22: // SLA D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_SLA);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x23: // SLA E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_SLA);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x24: // SLA H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_SLA);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x25: // SLA L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_SLA);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x26: // SLA (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_SLA);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 16;
      break;
    case 0x27: // SLA A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &cpu->temp1, 0, ALU_OP_SLA);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0x28: // SRA B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_SRA);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x29: // SRA C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_SRA);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x2A: // SRA D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_SRA);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x2B: // SRA E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_SRA);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x2C: // SRA H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_SRA);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x2D: // SRA L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_SRA);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x2E: // SRA (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_SRA);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 16;
      break;
    case 0x2F: // SRA A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &cpu->temp1, 0, ALU_OP_SRA);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0x38: // SRL B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_SRL);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x39: // SRL C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_SRL);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x3A: // SRL D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_SRL);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x3B: // SRL E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_SRL);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x3C: // SRL H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_SRL);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x3D: // SRL L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_SRL);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x3E: // SRL (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_SRL);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 16;
      break;
    case 0x3F: // SRL A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &cpu->temp1, 0, ALU_OP_SRL);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;
    
    case 0x40: // BIT 0, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x41: // BIT 0, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x42: // BIT 0, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x43: // BIT 0, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x44: // BIT 0, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x45: // BIT 0, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x46: // BIT 0, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_BIT);
      cpu->cycles += 12;
      break;
    case 0x47: // BIT 0, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    
    case 0x48: // BIT 1, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 1, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x49: // BIT 1, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 1, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x4A: // BIT 1, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 1, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x4B: // BIT 1, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 1, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x4C: // BIT 1, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 1, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x4D: // BIT 1, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 1, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x4E: // BIT 1, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 1, ALU_OP_BIT);
      cpu->cycles += 12;
      break;
    case 0x4F: // BIT 1, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 1, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    
    case 0x50: // BIT 2, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 2, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x51: // BIT 2, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 2, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x52: // BIT 2, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 2, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x53: // BIT 2, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 2, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x54: // BIT 2, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 2, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x55: // BIT 2, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 2, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x56: // BIT 2, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 2, ALU_OP_BIT);
      cpu->cycles += 12;
      break;
    case 0x57: // BIT 2, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 2, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    
    case 0x58: // BIT 3, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 3, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x59: // BIT 3, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 3, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x5A: // BIT 3, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 3, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x5B: // BIT 3, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 3, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x5C: // BIT 3, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 3, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x5D: // BIT 3, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 3, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x5E: // BIT 3, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 3, ALU_OP_BIT);
      cpu->cycles += 12;
      break;
    case 0x5F: // BIT 3, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 3, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    
    case 0x60: // BIT 4, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 4, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x61: // BIT 4, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 4, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x62: // BIT 4, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 4, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x63: // BIT 4, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 4, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x64: // BIT 4, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 4, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x65: // BIT 4, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 4, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x66: // BIT 4, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 4, ALU_OP_BIT);
      cpu->cycles += 12;
      break;
    case 0x67: // BIT 4, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 4, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    
    case 0x68: // BIT 5, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 5, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x69: // BIT 5, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 5, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x6A: // BIT 5, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 5, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x6B: // BIT 5, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 5, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x6C: // BIT 5, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 5, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x6D: // BIT 5, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 5, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x6E: // BIT 5, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 5, ALU_OP_BIT);
      cpu->cycles += 12;
      break;
    case 0x6F: // BIT 5, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 5, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    
    case 0x70: // BIT 6, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 6, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x71: // BIT 6, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 6, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x72: // BIT 6, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 6, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x73: // BIT 6, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 6, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x74: // BIT 6, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 6, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x75: // BIT 6, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 6, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x76: // BIT 6, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 6, ALU_OP_BIT);
      cpu->cycles += 12;
      break;
    case 0x77: // BIT 6, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 6, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    
    case 0x78: // BIT 7, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 7, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x79: // BIT 7, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 7, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x7A: // BIT 7, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 7, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x7B: // BIT 7, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 7, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x7C: // BIT 7, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 7, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x7D: // BIT 7, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 7, ALU_OP_BIT);
      cpu->cycles += 8;
      break;
    case 0x7E: // BIT 7, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 7, ALU_OP_BIT);
      cpu->cycles += 12;
      break;
    case 0x7F: // BIT 7, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 7, ALU_OP_BIT);
      cpu->cycles += 8;
      break;

    case 0x80: // RES 0, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_RES);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x81: // RES 0, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_RES);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x82: // RES 0, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_RES);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x83: // RES 0, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_RES);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x84: // RES 0, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_RES);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x85: // RES 0, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_RES);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x86: // RES 0, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_RES);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0x87: // RES 0, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_RES);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0x88: // RES 1, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 1, ALU_OP_RES);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x89: // RES 1, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 1, ALU_OP_RES);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x8A: // RES 1, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 1, ALU_OP_RES);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x8B: // RES 1, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 1, ALU_OP_RES);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x8C: // RES 1, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 1, ALU_OP_RES);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x8D: // RES 1, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 1, ALU_OP_RES);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x8E: // RES 1, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 1, ALU_OP_RES);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0x8F: // RES 1, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 1, ALU_OP_RES);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0x90: // RES 2, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 2, ALU_OP_RES);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x91: // RES 2, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 2, ALU_OP_RES);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x92: // RES 2, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 2, ALU_OP_RES);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x93: // RES 2, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 2, ALU_OP_RES);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x94: // RES 2, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 2, ALU_OP_RES);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x95: // RES 2, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 2, ALU_OP_RES);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x96: // RES 2, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 2, ALU_OP_RES);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0x97: // RES 2, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 2, ALU_OP_RES);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0x98: // RES 3, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 3, ALU_OP_RES);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x99: // RES 3, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 3, ALU_OP_RES);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0x9A: // RES 3, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 3, ALU_OP_RES);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x9B: // RES 3, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 3, ALU_OP_RES);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0x9C: // RES 3, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 3, ALU_OP_RES);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x9D: // RES 3, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 3, ALU_OP_RES);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0x9E: // RES 3, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 3, ALU_OP_RES);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0x9F: // RES 3, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 3, ALU_OP_RES);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0xA0: // RES 4, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 4, ALU_OP_RES);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xA1: // RES 4, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 4, ALU_OP_RES);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xA2: // RES 4, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 4, ALU_OP_RES);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xA3: // RES 4, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 4, ALU_OP_RES);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xA4: // RES 4, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 4, ALU_OP_RES);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xA5: // RES 4, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 4, ALU_OP_RES);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xA6: // RES 4, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 4, ALU_OP_RES);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xA7: // RES 4, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 4, ALU_OP_RES);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0xA8: // RES 5, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 5, ALU_OP_RES);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xA9: // RES 5, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 5, ALU_OP_RES);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xAA: // RES 5, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 5, ALU_OP_RES);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xAB: // RES 5, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 5, ALU_OP_RES);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xAC: // RES 5, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 5, ALU_OP_RES);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xAD: // RES 5, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 5, ALU_OP_RES);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xAE: // RES 5, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 5, ALU_OP_RES);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xAF: // RES 5, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 5, ALU_OP_RES);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;
    
    case 0xB0: // RES 6, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 6, ALU_OP_RES);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xB1: // RES 6, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 6, ALU_OP_RES);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xB2: // RES 6, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 6, ALU_OP_RES);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xB3: // RES 6, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 6, ALU_OP_RES);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xB4: // RES 6, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 6, ALU_OP_RES);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xB5: // RES 6, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 6, ALU_OP_RES);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xB6: // RES 6, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 6, ALU_OP_RES);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xB7: // RES 6, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 6, ALU_OP_RES);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;
    
    case 0xB8: // RES 7, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 7, ALU_OP_RES);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xB9: // RES 7, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 7, ALU_OP_RES);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xBA: // RES 7, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 7, ALU_OP_RES);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xBB: // RES 7, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 7, ALU_OP_RES);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xBC: // RES 7, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 7, ALU_OP_RES);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xBD: // RES 7, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 7, ALU_OP_RES);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xBE: // RES 7, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 7, ALU_OP_RES);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xBF: // RES 7, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 7, ALU_OP_RES);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0xC0: // SET 0, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_SET);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xC1: // SET 0, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_SET);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xC2: // SET 0, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_SET);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xC3: // SET 0, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_SET);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xC4: // SET 0, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_SET);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xC5: // SET 0, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 0, ALU_OP_SET);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xC6: // SET 0, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 0, ALU_OP_SET);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xC7: // SET 0, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_SET);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0xC8: // SET 1, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 1, ALU_OP_SET);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xC9: // SET 1, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 1, ALU_OP_SET);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xCA: // SET 1, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 1, ALU_OP_SET);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xCB: // SET 1, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 1, ALU_OP_SET);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xCC: // SET 1, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 1, ALU_OP_SET);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xCD: // SET 1, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 1, ALU_OP_SET);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xCE: // SET 1, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 1, ALU_OP_SET);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xCF: // SET 1, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 1, ALU_OP_SET);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0xD0: // SET 2, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 2, ALU_OP_SET);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xD1: // SET 2, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 2, ALU_OP_SET);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xD2: // SET 2, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 2, ALU_OP_SET);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xD3: // SET 2, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 2, ALU_OP_SET);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xD4: // SET 2, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 2, ALU_OP_SET);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xD5: // SET 2, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 2, ALU_OP_SET);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xD6: // SET 2, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 2, ALU_OP_SET);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xD7: // SET 2, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 2, ALU_OP_SET);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0xD8: // SET 3, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 3, ALU_OP_SET);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xD9: // SET 3, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 3, ALU_OP_SET);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xDA: // SET 3, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 3, ALU_OP_SET);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xDB: // SET 3, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 3, ALU_OP_SET);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xDC: // SET 3, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 3, ALU_OP_SET);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xDD: // SET 3, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 3, ALU_OP_SET);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xDE: // SET 3, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 3, ALU_OP_SET);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xDF: // SET 3, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 3, ALU_OP_SET);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0xE0: // SET 4, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 4, ALU_OP_SET);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xE1: // SET 4, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 4, ALU_OP_SET);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xE2: // SET 4, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 4, ALU_OP_SET);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xE3: // SET 4, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 4, ALU_OP_SET);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xE4: // SET 4, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 4, ALU_OP_SET);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xE5: // SET 4, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 4, ALU_OP_SET);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xE6: // SET 4, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 4, ALU_OP_SET);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xE7: // SET 4, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 4, ALU_OP_SET);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0xE8: // SET 5, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 5, ALU_OP_SET);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xE9: // SET 5, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 5, ALU_OP_SET);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xEA: // SET 5, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 5, ALU_OP_SET);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xEB: // SET 5, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 5, ALU_OP_SET);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xEC: // SET 5, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 5, ALU_OP_SET);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xED: // SET 5, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 5, ALU_OP_SET);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xEE: // SET 5, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 5, ALU_OP_SET);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xEF: // SET 5, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 5, ALU_OP_SET);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0xF0: // SET 6, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 6, ALU_OP_SET);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xF1: // SET 6, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 6, ALU_OP_SET);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xF2: // SET 6, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 6, ALU_OP_SET);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xF3: // SET 6, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 6, ALU_OP_SET);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xF4: // SET 6, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 6, ALU_OP_SET);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xF5: // SET 6, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 6, ALU_OP_SET);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xF6: // SET 6, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 6, ALU_OP_SET);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xF7: // SET 6, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 6, ALU_OP_SET);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    case 0xF8: // SET 7, B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 7, ALU_OP_SET);
      loadHigh(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xF9: // SET 7, C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 7, ALU_OP_SET);
      loadLow(&cpu->bc, temp1);
      cpu->cycles += 8;
      break;
    case 0xFA: // SET 7, D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 7, ALU_OP_SET);
      loadHigh(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xFB: // SET 7, E
      temp1 = getLow(cpu->de);
      alu8(cpu, &temp1, 7, ALU_OP_SET);
      loadLow(&cpu->de, temp1);
      cpu->cycles += 8;
      break;
    case 0xFC: // SET 7, H
      temp1 = getHigh(cpu->hl);
      alu8(cpu, &temp1, 7, ALU_OP_SET);
      loadHigh(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xFD: // SET 7, L
      temp1 = getLow(cpu->hl);
      alu8(cpu, &temp1, 7, ALU_OP_SET);
      loadLow(&cpu->hl, temp1);
      cpu->cycles += 8;
      break;
    case 0xFE: // SET 7, (HL)
      temp1 = cpu->memory[cpu->hl];
      alu8(cpu, &temp1, 7, ALU_OP_SET);
      cpu->memory[cpu->hl] = temp1;
      cpu->cycles += 12;
      break;
    case 0xFF: // SET 7, A
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 7, ALU_OP_SET);
      loadHigh(&cpu->af, temp1);
      cpu->cycles += 8;
      break;

    default:
      return;
    
}

void printState(VirtZ80 *cpu) {
  printf(
    "AF=0x%04x BC=0x%04x DE=0x%04x HL=0x%04x SP=0x%04x PC=0x%04x T=0x%04x\n",
    cpu->af, cpu->bc, cpu->de, cpu->hl, cpu->sp, cpu->pc, cpu->cycles
  );
}


int main(int argc, char **argv) {
  if (argc < 2) {
    perror("Usage: %s <program>\n");
    exit(1);
  }
  FILE *source = fopen(argv[1], "rb");
  if (source == NULL) {
    perror("fopen");
    exit(1);
  }

  VirtZ80 cpu;
  memset(&cpu, 0, sizeof(VirtZ80));

  fseek(source, 0, SEEK_END);
  long file_size = ftell(source);
  fseek(source, 0, SEEK_SET);

  char *src_hex = malloc(sizeof(char) * file_size);

  int i = 0;
  while (fread(&src_hex[i], 1, 1, source)) {
    i++;
  }

  memcpy(cpu.memory, src_hex, file_size);

  printf("Loaded %d bytes\n", i);

  execute(&cpu);
  printState(&cpu);
  return 0;
}