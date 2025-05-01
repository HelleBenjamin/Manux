
;
; A configurable CRT for bare-metal targets
; Configured for Manux
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

    EXTERN    KERNEL_ENTRY           ;main() is always external to crt0 code
    PUBLIC    __Exit         ;jp'd to by exit()
    PUBLIC    l_dcal          ;jp(hl)

IF DEFINED_CRT_ORG_BSS
    defc    __crt_org_bss = CRT_ORG_BSS
ENDIF

IFNDEF      CRT_ORG_CODE
    defc    CRT_ORG_CODE = 0x0000
ENDIF

IF CRT_ORG_CODE = 0x0000
    ; By default we don't have any rst handlers. The kernel handles them
    defc    TAR__crt_enable_rst = $0000
ENDIF

    ; Default, don't change the stack pointer
    defc    TAR__register_sp = -1
    ; Default, 32 functions can be registered for atexit()
    defc    TAR__clib_exit_stack_size = 32
    ; Default, halt loop
    defc    TAR__crt_on_exit = 0x10001

    defc    __CPU_CLOCK = 4000000
    INCLUDE "crt/classic/crt_rules.inc"


    org    	CRT_ORG_CODE


IF CRT_ORG_CODE = 0x0000
    jp      start
    INCLUDE "crt/classic/crt_z80_rsts.inc"
ENDIF

start:
    INCLUDE "crt/classic/crt_init_sp.inc"
    ; Setup BSS memory and perform other initialisation
    call    crt0_init

    ; Setup heap if required
    INCLUDE "crt/classic/crt_init_heap.inc"


    ; Entry to the user code
    call    KERNEL_ENTRY
    ; Exit code is in hl
__Exit:
    ; crt0_exit any resources
    ret

    ; Set the interrupt mode on exit
    ;INCLUDE "crt/classic/crt_exit_eidi.inc"

    ; How does the program end?
    ;INCLUDE "crt/classic/crt_terminate.inc"

PUBLIC fputc_cons_native
PUBLIC _fputc_cons_native

fputc_cons_native:    
_fputc_cons_native:
    EXTERN TRANSMIT_CHAR
    ;ld hl, 2
    ;add hl, sp ; get the address of the character
    ;push af
    ;push de
    ;ld a, $04
    ;ld de, 1
    ;call SYSCALL_VECTOR
    ;pop de
    ;pop af

    ld hl, 2
    add hl, sp ; get the address of the character
    ld a, (hl)
    call TRANSMIT_CHAR
    ret

PUBLIC fgetc_cons
PUBLIC _fgetc_cons

fgetc_cons:
_fgetc_cons:
    EXTERN RECEIVE_CHAR
    call RECEIVE_CHAR
    ld l, a ; char in l
    ld h, 0
    ret

l_dcal:
    jp      (hl)

    INCLUDE "crt/classic/crt_runtime_selection.inc"

    ; If we were given a model then use it
IF DEFINED_CRT_MODEL
    defc __crt_model = CRT_MODEL
ELSE
    defc __crt_model = 1
ENDIF
    INCLUDE	"crt/classic/crt_section.inc"
