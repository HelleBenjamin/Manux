; This program should print 0123...9
init:
 ld c, 10 ; counter
 ld a, 0x30 ; '0'
loop:
 rst 0x08 ; stdout
 inc a
 dec c
 jr z, end
 jr loop
end:
 ld a, 0 ; exit syscall
 ld hl, 0
 rst 0x20
