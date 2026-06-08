  ld c, 10 ; counter, loop 10 times
  dec c ; loop:
  xor a ; check if zero
  cp c
  jr z, 0x05 ; if zero jump to end
  ld a, 0x30 ; char '0'
  rst 8 ; print it
  jr 0xf6 ; jump back to loop
  ld a, 0 ; end, sys_exit
  ld hl, 0
  rst 0x20 ; syscall