SECTION code_driver
SECTION code_driver_terminal_output

PUBLIC term_01_output_char_oterm_msg_printc
PUBLIC console_01_output_char_proc_linefeed

term_01_output_char_oterm_msg_printc:

;   * OTERM_MSG_PRINTC
;
;     enter  :  c = ascii code
;               b = 255 if not supplied by iterm (safely ignore)
;               l = absolute x coordinate
;               h = absolute y coordinate
;     can use:  af, bc, de, hl, af'
;
;     Print the char to screen at given character coordinate.
    ; coordinates are ignored by Manux
    ld a, c ; character
    rst 0x08
    ret

console_01_output_char_proc_linefeed:
    ; custom newline handler, this prints the new position

    push af
    ld a, 13 ; '\r'
    rst 0x08

    ld a, 10 ; '\n'
    rst 0x08
    pop af
    ret
