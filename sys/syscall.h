#ifndef SYSCALL_H
#define SYSCALL_H

#define SYS_EXIT 0
#define SYS_WRITE 1
#define SYS_READ 2
#define SYS_GETS 3
#define SYS_PUTS 4
#define SYS_EXEC 5
#define SYS_GETINFO 6
#define SYS_RAND 7

void sysc_exit(short code) __z88dk_fastcall;
void sysc_write(short port, short len, char *str);
void sysc_read(short port, short len, char *str);
void sysc_gets(short len, char *str);
void sysc_puts(short len, char *str);
void sysc_exec(short len, short *addr);
void sysc_getinfo(char *str);
void sysc_rand(short *buf);

#endif