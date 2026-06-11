  ld c, 10 ; counter, loop 10 times
loop:
  dec c ; loop:
  xor a ; check if zero
  cp c
  jr z, end ; if zero jump to end
  ld a, 0x30 ; char '0'
  rst 8 ; print it
  jr loop ; jump back to loop
end:
  ld a, 0 ; end, sys_exit
  ld hl, 0
  rst 0x20 ; syscall