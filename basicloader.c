// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int main(int argc, char **argv) {
  if (argc < 3) {
    printf("Usage: %s <hex_address> <input_file> <output_file>\n", argv[0]);
    exit(1);
  }

  char *hex_address = argv[1]; // Address must be in hexadecimal

  FILE *source = fopen(argv[2], "rb");
  if (source == NULL) {
    perror("fopen");
    exit(1);
  }
  FILE *output = fopen(argv[3], "wb");
  if (output == NULL) {
    perror("fopen");
    exit(1);
  }

  fseek(source, 0, SEEK_END);
  long file_size = ftell(source);
  fseek(source, 0, SEEK_SET);

  char *src_hex = malloc(sizeof(char) * file_size);

  int i = 0;
  while (fread(&src_hex[i], 1, 1, source)) {
    i++;
  }

  int line = 10;
  int addr = (int)strtol(hex_address, NULL, 16); // Convert hex address to integer
  int size = file_size;

  // Main program
  fprintf(output, "0 REM MANUX HEX LOADER FOR BASIC 4.7, SIZE: %d bytes\n", size);
  fprintf(output, "1 POKE 32840-65536, 195\n"); // Subtract because BASIC treats numbers as signed
  fprintf(output, "2 POKE 32841-65536, %d\n", addr & 0xFF);
  fprintf(output, "3 POKE 32842-65536, %d\n", addr >> 8);
  fprintf(output, "4 FOR I = %d-65536 TO %d-65536\n", addr, addr+size-1);
  fprintf(output, "5 READ A\n");
  fprintf(output, "6 POKE I, A\n");
  fprintf(output, "7 NEXT I\n");

  printf("Writing %d bytes to BASIC file...\n", i);
  printf("Size: %d bytes, Address: 0x%X\n", size, addr);
  printf("Writing from 0x%04X to 0x%04X\n", addr, addr + size - 1);

  int dataWritten = 0;
  while (dataWritten < i) { // Write the data
    int lineLen = 9; // Including %d DATA
    fprintf(output, "%d DATA ", line);
    while (lineLen <= 70 && dataWritten < i) {
      fprintf(output, "%d", src_hex[dataWritten] & 0xFF);
      dataWritten++;
      lineLen += 3;
      if (lineLen < 70 && dataWritten < i) {
        fprintf(output, ",");
        lineLen += 2;
      }
    }
    fprintf(output, "\n");
    line++;
    addr++;
  }

  fprintf(output, "%d A=USR(0)\n", line); // This starts the kernel

  fclose(source);
  fclose(output);
  free(src_hex);

  return 0;
}

