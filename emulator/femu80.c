#include "femu80.h"

// Fast Emulator for Z80

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

void setCoreRoutines() {

}

void updateFlags8(VirtZ80 *cpu, uint16_t alu_result) {
  cpu->af = cpu->af | alu_result == 0 ? FLAG_Z : 0x00 | (alu_result & 0x80) < 0 ? FLAG_S : 0x00 | (alu_result & 0x100) ? FLAG_C : 0x00 | (alu_result & 0x10) ? FLAG_H : 0x00 | alu_result < -128 || alu_result > 127 ? FLAG_P : 0x00;
}

void updateFlags16(VirtZ80 *cpu, uint32_t alu_result) {
  cpu->af = cpu->af | alu_result == 0 ? FLAG_Z : 0x00 | (alu_result & 0x8000) < 0 ? FLAG_S : 0x00 | (alu_result & 0x10000) ? FLAG_C : 0x00 | (alu_result & 0x100) ? FLAG_H : 0x00 | alu_result < -32768 || alu_result > 32767 ? FLAG_P : 0x00;
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
      result = *dest + value + ((cpu->af & 0x00FF) & FLAG_C);
      break;
    case ALU_OP_SUB:
      result = *dest - value;
      break;
    case ALU_OP_SBC:
      result = *dest - value - ((cpu->af & 0x00FF) & FLAG_C);
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
      result = (*dest << 1) | (cpu->af & 0x00FF) & FLAG_C;
      break;
    case ALU_OP_RR:
      result = (*dest >> 1) | ((cpu->af & 0x00FF) & FLAG_C) << 7;
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
      result = *dest + value + ((cpu->af & 0x00FF) & FLAG_C);
      break;
    case ALU_OP_SUB:
      result = *dest - value;
      break;
    case ALU_OP_SBC:
      result = *dest - value - ((cpu->af & 0x00FF) & FLAG_C);
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
      cpu->memory[cpu->bc] = (cpu->af & 0xFF00);
      cpu->cycles += 7;
      break;
    case 0x03: // INC BC
      cpu->bc++;
      cpu->cycles += 6;
      break;
    case 0x04: // INC B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_INC);
      loadHigh(cpu->bc, temp1);
      cpu->cycles += 4;
      break;
    case 0x05: // DEC B
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadHigh(cpu->bc, temp1);
      cpu->cycles += 4;
      break;
    case 0x06: // LD B, n
      loadHigh(cpu->bc, fByte(cpu));
      cpu->cycles += 7;
    case 0x07: // RLCA
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_RLC);
      loadHigh(cpu->af, temp1);
      cpu->cycles += 4;
      break;
    0x08: // EX AF, AF'
      exchange(&cpu->af, &cpu->afa);
      cpu->cycles += 4;
      break;
    0x09: // ADD HL, BC
      alu16(cpu, &cpu->hl, cpu->bc, ALU_OP_ADD);
      cpu->cycles += 11;
      break;
    0x0A: // LD A, (BC)
      temp1 = cpu->memory[cpu->bc];
      loadHigh(cpu->af, temp1);
      cpu->cycles += 7;
      break;
    0x0B: // DEC BC
      cpu->bc--;
      cpu->cycles += 6;
      break;
    0x0C: // INC C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_INC);
      loadHigh(cpu->bc, temp1);
      cpu->cycles += 4;
      break;
    0x0D: // DEC C
      temp1 = getLow(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadHigh(cpu->bc, temp1);
      cpu->cycles += 4;
      break;
    0x0E: // LD C, n
      loadLow(cpu->bc, fByte(cpu));
      cpu->cycles += 7;
      break;
    0x0F: // RRCA
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_RRC);
      loadHigh(cpu->af, temp1);
      cpu->cycles += 4;
      break;
    0x10: // DJNZ d
      temp1 = getHigh(cpu->bc);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadHigh(cpu->bc, temp1);
      if (temp1 != 0) {
        cpu->pc += (int8_t)fByte(cpu);
        cpu->cycles += 13;
        break;
      }
      cpu->cycles += 8;
      break;
    0x11: // LD DE, nn
      cpu->de = fWord(cpu);
      cpu->cycles += 10;
      break;
    0x12: // LD (DE), A
      cpu->memory[cpu->de] = getHigh(cpu->af);
      cpu->cycles += 7;
      break;
    0x13: // INC DE
      cpu->de++;
      cpu->cycles += 6;
      break;
    0x14: // INC D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_INC);
      loadHigh(cpu->de, temp1);
      cpu->cycles += 4;
      break;
    0x15: // DEC D
      temp1 = getHigh(cpu->de);
      alu8(cpu, &temp1, 0, ALU_OP_DEC);
      loadHigh(cpu->de, temp1);
      cpu->cycles += 4;
      break;
    0x16: // LD D, n
      loadHigh(cpu->de, fByte(cpu));
      cpu->cycles += 7;
      break;
    0x17: // RLA
      temp1 = getHigh(cpu->af);
      alu8(cpu, &temp1, 0, ALU_OP_RL);
      loadHigh(cpu->af, temp1);
      cpu->cycles += 4;
      break;
    0x18: // JR d
      cpu->pc += (int8_t)fByte(cpu);
      cpu->cycles += 12;
      break;
    0x19: // ADD HL, DE
      alu16(cpu, &cpu->hl, cpu->de, ALU_OP_ADD);
      cpu->cycles += 11;
      break;
    0x1A: // LD A, (DE)
      temp1 = cpu->memory[cpu->de];
      loadHigh(cpu->af, temp1);
      cpu->cycles += 7;
      break;
    0x1B: // DEC DE
      cpu->de--;
      cpu->cycles += 6;
    default:
      cpu->cycles += 4;
      break;
  }
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

}