;
; CRT configurated for Manux userland programs
;
;

    MODULE z80_crt0 

;-------
; Include zcc_opt.def to find out information about us
;-------

    defc    crt0 = 1
    INCLUDE "zcc_opt.def"

;-------
; Some general scope declarations
;-------

    EXTERN    _main           ;main() is always external to crt0 code
    PUBLIC    __Exit         ;jp'd to by exit()
    PUBLIC    l_dcal          ;jp(hl)

IF DEFINED_CRT_ORG_BSS
    defc    __crt_org_bss = CRT_ORG_BSS
ENDIF

; if org isn't defined, default to 0x4100
IFNDEF      CRT_ORG_CODE
    defc    CRT_ORG_CODE = 0x4100
ENDIF

    ; Default, don't change the stack pointer
    defc    TAR__register_sp = -1
    ; Default, 32 functions can be registered for atexit()
    defc    TAR__clib_exit_stack_size = 32
    ; Default, halt loop
    defc    TAR__crt_on_exit = 0x10001

    defc    __CPU_CLOCK = 4000000

    org    	CRT_ORG_CODE


IFDEF CRT_INCLUDE_PREAMBLE
    INCLUDE "crt_preamble.asm"
ENDIF

start:
    ; The kernel setups all the necessary things
    ; Setup BSS memory and perform other initialisation

    ; cmdline enable, argc and argv
    ; need to some magic to get it working
    IF CRT_ENABLE_COMMANDLINE=2
        ; hl = argv pointer
        ; to get the pointer table, using a formula: ARGV_SIZE - (argc+1)*2
        ; ARGV_SIZE = 242 (bytes)
        push bc
        ld a, c
        inc a ; argc+1
        add a, a ; *2
        ld c, a ; temp
        ld a, 242
        sub a, c ; ARGV_SIZE-(argc+1)*2
        add a, 0x0C ; offset of argv in PIH
        ld l, a
        ld h, 0x40
        pop bc 
        push hl ; argv
        push bc ; argc
    ENDIF

    call    crt0_init

    ; Setup heap if required
    INCLUDE "crt/classic/crt_init_heap.inc"

    ; Entry to the user code
    call    _main
    ; Exit code is in hl
__Exit:
    ; crt0_exit any resources
    call    crt0_exit

    ; Exit syscall
    ld a, 0 ; sys_exit
    rst 0x20

l_dcal:
    jp      (hl)

;INCLUDE "crt/classic/crt_runtime_selection.inc"

    ; If we were given a model then use it
IF DEFINED_CRT_MODEL
    defc __crt_model = CRT_MODEL
ELIF DEFINED_CRT_ORG_BSS
    ;; If BSS is defined, then assume we're ROM model
    defc __crt_model = 1
ENDIF
    INCLUDE	"crt/classic/crt_section.inc"
