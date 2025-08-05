// DEBUG ONLY

/*char hextobyte(char *hex) __z88dk_fastcall {
  static char byte;
  byte = 0;
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
}*/

/*void z80ld() {
  // Very small Z80 program loader, loads hex code to a file and executes it
  // Create files
  sysc_create("Z80PROG"); // File to hold program
  create_file("Z80ASM "); // Executable program

  char *program = get_file_blockptr("Z80PROG"); // Get block pointers
  char *program_exec = get_file_blockptr("Z80ASM ");

  read(STDIN_FILENO, program, 0xFF); // Read hex code to file
  for (unsigned char i = 0; i < 0xFF; ++i) {
    program_exec[i] = hextobyte(&program[i * 2]); // Convert hex to bytes
  }
  newline(); // Newline for fun
  fork(); // Fork the process, new process will execute the program
  sysc_execs("Z80ASM ", "0123456789"); // Execute the program

}*/

/*void print_addr(short *addr, char count) {
  for (unsigned char i = 0; i < count; ++i) {
    puth(addr[i]);
    putchar(' ');
  }
  newline();
}*/

/*else if (strcmp(command, "test") == 0) { // Debugging, writes a test file and reads it
      sysc_create("TESTFIL");
      char testfd;
      sysc_open("TESTFIL", &testfd);
      char *testmsg = "Hello World!\n\r";
      sysc_write(testfd, strlen(testmsg), testmsg);
      char testbuf[32] = {0};
      sysc_read(testfd, strlen(testmsg), testbuf);
      sysc_write(STDOUT_FILENO, strlen(testbuf), testbuf);
    } else if (strncmp(command, "cat ", 4) == 0) {
      char *filename = command + 4;
      char *filebuf = get_file_blockptr(filename);
      if (filebuf != NULL) {
        read_file(filename, get_file_size(filename), filebuf);
        sysc_write(STDOUT_FILENO, get_file_size(filename), filebuf);
      } else {
        puts("File not found\n\r");
      }
    } else if (strncmp(command, "./", 2) == 0) {
      char filename[8] = {0};
      strncpy(filename, command + 2, 7); // Copy filename from command
      filename[7] = '\0'; // Null terminate the string
      //short *filebuf = get_file_blockptr(filename);
      //filebuf += 4;
      fork(); // Fork the process
      //sysc_exec(filebuf); // Execute the file
      sysc_execs(filename, NULL); // Execute the file with arguments
    }*/