#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int main(int argc, char **argv) {
  if (argc < 2) {
    printf("Usage: %s <hex>\n", argv[0]);
    exit(1);
  }

  FILE *source = fopen(argv[1], "rb");
  if (source == NULL) {
    perror("fopen");
    exit(1);
  }
  FILE *output = fopen(argv[2], "wb");
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

  /*   Example 1 output

  0 REM BASIC HEX LOADER FOR Z80
  1 POKE &H8048, &HC3
  2 POKE &H8049, &H00
  3 POKE &H804A, &H99
  4 FOR I = &H9900 TO &H9903
  5 READ A
  6 POKE I, A
  7 NEXT I
  8 DATA 62, 48, 207, 201
  

  */


  int line = 10;
  int addr = 0xB004;
  int size = file_size;
  fprintf(output, "0 REM BASIC HEX LOADER FOR Z80, SIZE: %d\n", size);
  fprintf(output, "1 POKE &H8048, &HC3\n");
  fprintf(output, "2 POKE &H8049, &H04\n");
  fprintf(output, "3 POKE &H804A, &HB0\n");
  fprintf(output, "4 FOR I = &H%04x TO &H%04x\n", addr, addr+size-1);
  fprintf(output, "5 READ A\n");
  fprintf(output, "6 POKE I, A\n");
  fprintf(output, "7 NEXT I\n");

  int dataWritten = 0;
  while (dataWritten < i) {
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
  fprintf(output, "%d A=USR(0)\n", line);

  fclose(source);
  fclose(output);
  free(src_hex);
  return 0;
}
