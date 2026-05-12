                    di                                      ;[0000] f3
                    im        1                             ;[0001] ed 56
                    jp        __Start                       ;[0003] c3 72 00
                    nop                                     ;[0006] 00
                    nop                                     ;[0007] 00
                    jp        _z80_rst_08h                  ;[0008] c3 cb 07
                    ld        e,d                           ;[000b] 5a
                    jr        c,$0046                       ;[000c] 38 38
                    ld        b,h                           ;[000e] 44
                    ld        c,e                           ;[000f] 4b
                    jp        _z80_rst_10h                  ;[0010] c3 d0 07
                    ld        ($332e),a                     ;[0013] 32 2e 33
                    jr        nc,$0018                      ;[0016] 30 00
                    jp        __thread_block_timeout        ;[0018] c3 2e 00
                    dec       de                            ;[001b] 1b
                    dec       de                            ;[001c] 1b
                    dec       de                            ;[001d] 1b
l_dec_de:
                    ret                                     ;[001e] c9

                    nop                                     ;[001f] 00
                    jp        SYSCALL_DISPATCH              ;[0020] c3 b5 02
                    dec       bc                            ;[0023] 0b
                    dec       bc                            ;[0024] 0b
                    dec       bc                            ;[0025] 0b
l_dec_bc:
                    ret                                     ;[0026] c9

                    nop                                     ;[0027] 00
                    jp        __thread_block_timeout        ;[0028] c3 2e 00
                    pop       hl                            ;[002b] e1
                    pop       hl                            ;[002c] e1
                    pop       hl                            ;[002d] e1
__thread_block_timeout:
                    ret                                     ;[002e] c9

                    nop                                     ;[002f] 00
                    jp        __thread_block_timeout        ;[0030] c3 2e 00
l_jpix:
                    jp        (iy)                          ;[0033] fd e9
l_jpiy:
                    jp        (ix)                          ;[0035] dd e9
                    nop                                     ;[0037] 00
                    jp        _z80_rst_38h                  ;[0038] c3 8d 07
                    ld        (hl),a                        ;[003b] 77
                    inc       hl                            ;[003c] 23
                    ld        (hl),a                        ;[003d] 77
                    inc       hl                            ;[003e] 23
                    ld        (hl),a                        ;[003f] 77
                    inc       hl                            ;[0040] 23
                    ld        (hl),a                        ;[0041] 77
                    inc       hl                            ;[0042] 23
                    ld        (hl),a                        ;[0043] 77
                    inc       hl                            ;[0044] 23
                    ld        (hl),a                        ;[0045] 77
                    inc       hl                            ;[0046] 23
                    ld        (hl),a                        ;[0047] 77
                    inc       hl                            ;[0048] 23
                    ld        (hl),a                        ;[0049] 77
                    inc       hl                            ;[004a] 23
                    ld        (hl),a                        ;[004b] 77
                    inc       hl                            ;[004c] 23
                    ld        (hl),a                        ;[004d] 77
                    inc       hl                            ;[004e] 23
                    ld        (hl),a                        ;[004f] 77
                    inc       hl                            ;[0050] 23
                    ld        (hl),a                        ;[0051] 77
                    inc       hl                            ;[0052] 23
                    ld        (hl),a                        ;[0053] 77
                    inc       hl                            ;[0054] 23
                    ld        (hl),a                        ;[0055] 77
                    inc       hl                            ;[0056] 23
                    ld        (hl),a                        ;[0057] 77
                    inc       hl                            ;[0058] 23
                    ld        (hl),a                        ;[0059] 77
                    inc       hl                            ;[005a] 23
l_setmem_hl:
                    ret                                     ;[005b] c9

                    inc       hl                            ;[005c] 23
                    inc       hl                            ;[005d] 23
                    inc       hl                            ;[005e] 23
                    inc       hl                            ;[005f] 23
                    inc       hl                            ;[0060] 23
                    inc       hl                            ;[0061] 23
                    inc       hl                            ;[0062] 23
                    inc       hl                            ;[0063] 23
l_inc_hl:
                    ret                                     ;[0064] c9

                    nop                                     ;[0065] 00
                    jp        l_retn                        ;[0066] c3 28 01
                    ld        hl,$2a02                      ;[0069] 21 02 2a
                    ld        bc,$0080                      ;[006c] 01 80 00
                    call      asm_heap_init                 ;[006f] cd db 00
__Start:
                    di                                      ;[0072] f3
__Restart:
                    ld        sp,$ffff                      ;[0073] 31 ff ff
__Restart_2:
                    ld        hl,$1684                      ;[0076] 21 84 16
                    ld        de,$1684                      ;[0079] 11 84 16
                    ld        bc,$00d8                      ;[007c] 01 d8 00
                    call      asm_memcpy                    ;[007f] cd b2 01
                    im        1                             ;[0082] ed 56
                    ld        hl,$ffff                      ;[0084] 21 ff ff
                    add       hl,sp                         ;[0087] 39
                    ld        bc,$2ac0                      ;[0088] 01 c0 2a
                    or        a                             ;[008b] b7
                    sbc       hl,bc                         ;[008c] ed 42
                    jp        c,__Exit                      ;[008e] da a9 00
                    ld        bc,$020e                      ;[0091] 01 0e 02
                    sbc       hl,bc                         ;[0094] ed 42
                    jp        c,__Exit                      ;[0096] da a9 00
                    ld        bc,$000f                      ;[0099] 01 0f 00
                    add       hl,bc                         ;[009c] 09
                    ld        b,h                           ;[009d] 44
                    ld        c,l                           ;[009e] 4d
                    ld        hl,$2ac0                      ;[009f] 21 c0 2a
                    call      asm_heap_init                 ;[00a2] cd db 00
                    ei                                      ;[00a5] fb
                    call      KERNEL_ENTRY                  ;[00a6] cd 02 02
__Exit:
                    push      hl                            ;[00a9] e5
                    di                                      ;[00aa] f3
                    pop       hl                            ;[00ab] e1
                    halt                                    ;[00ac] 76
                    jr        $00ad                         ;[00ad] 18 fe
WRITE_DISK:
                    out       ($16),a                       ;[00af] d3 16
                    ld        a,e                           ;[00b1] 7b
                    out       ($11),a                       ;[00b2] d3 11
                    ld        a,d                           ;[00b4] 7a
                    out       ($12),a                       ;[00b5] d3 12
                    ld        a,l                           ;[00b7] 7d
                    out       ($13),a                       ;[00b8] d3 13
                    ld        a,h                           ;[00ba] 7c
                    out       ($14),a                       ;[00bb] d3 14
                    ld        a,$02                         ;[00bd] 3e 02
                    out       ($10),a                       ;[00bf] d3 10
                    nop                                     ;[00c1] 00
                    in        a,($15)                       ;[00c2] db 15
                    ret                                     ;[00c4] c9

READ_DISK:
                    out       ($16),a                       ;[00c5] d3 16
                    ld        a,e                           ;[00c7] 7b
                    out       ($11),a                       ;[00c8] d3 11
                    ld        a,d                           ;[00ca] 7a
                    out       ($12),a                       ;[00cb] d3 12
                    ld        a,l                           ;[00cd] 7d
                    out       ($13),a                       ;[00ce] d3 13
                    ld        a,h                           ;[00d0] 7c
                    out       ($14),a                       ;[00d1] d3 14
                    ld        a,$01                         ;[00d3] 3e 01
                    out       ($10),a                       ;[00d5] d3 10
                    nop                                     ;[00d7] 00
                    in        a,($15)                       ;[00d8] db 15
                    ret                                     ;[00da] c9

asm_heap_init:
                    ld        d,h                           ;[00db] 54
                    ld        e,l                           ;[00dc] 5d
                    push      hl                            ;[00dd] e5
                    push      bc                            ;[00de] c5
                    ld        c,$01                         ;[00df] 0e 01
                    call      asm_mtx_init                  ;[00e1] cd e3 01
                    jp        c,$00fe                       ;[00e4] da fe 00
                    ld        hl,$0006                      ;[00e7] 21 06 00
                    add       hl,de                         ;[00ea] 19
                    ex        de,hl                         ;[00eb] eb
                    pop       bc                            ;[00ec] c1
                    add       hl,bc                         ;[00ed] 09
                    xor       a                             ;[00ee] af
                    dec       hl                            ;[00ef] 2b
                    ld        (hl),a                        ;[00f0] 77
                    dec       hl                            ;[00f1] 2b
                    ld        (hl),a                        ;[00f2] 77
                    ex        de,hl                         ;[00f3] eb
                    ld        (hl),e                        ;[00f4] 73
                    inc       hl                            ;[00f5] 23
                    ld        (hl),d                        ;[00f6] 72
                    inc       hl                            ;[00f7] 23
                    call      $0053                         ;[00f8] cd 53 00
                    pop       hl                            ;[00fb] e1
                    ret                                     ;[00fc] c9

                    pop       hl                            ;[00fd] e1
                    pop       hl                            ;[00fe] e1
                    pop       hl                            ;[00ff] e1
error_enolck_zc:
                    ld        l,$ff                         ;[0100] 2e ff
errno_zc:
                    ld        h,$00                         ;[0102] 26 00
                    ld        (_errno),hl                   ;[0104] 22 00 2a
                    jp        __ch_system                   ;[0107] c3 0e 01
                    pop       hl                            ;[010a] e1
                    pop       hl                            ;[010b] e1
                    pop       hl                            ;[010c] e1
                    pop       hl                            ;[010d] e1
__ch_system:
                    ld        hl,$0000                      ;[010e] 21 00 00
                    scf                                     ;[0111] 37
                    ret                                     ;[0112] c9

                    pop       hl                            ;[0113] e1
                    pop       hl                            ;[0114] e1
                    pop       hl                            ;[0115] e1
error_divide_by_zero_mc:
                    ld        l,$ff                         ;[0116] 2e ff
errno_mc:
                    ld        h,$00                         ;[0118] 26 00
                    ld        (_errno),hl                   ;[011a] 22 00 2a
                    jp        error_mc                      ;[011d] c3 23 01
                    pop       hl                            ;[0120] e1
                    pop       hl                            ;[0121] e1
                    pop       hl                            ;[0122] e1
error_mc:
                    ld        hl,$ffff                      ;[0123] 21 ff ff
                    scf                                     ;[0126] 37
                    ret                                     ;[0127] c9

l_retn:
                    retn                                    ;[0128] ed 45

l_neg_de:
                    ld        a,e                           ;[012a] 7b
                    cpl                                     ;[012b] 2f
                    ld        e,a                           ;[012c] 5f
                    ld        a,d                           ;[012d] 7a
                    cpl                                     ;[012e] 2f
                    ld        d,a                           ;[012f] 57
                    inc       de                            ;[0130] 13
                    ret                                     ;[0131] c9

l_neg_hl:
                    ld        a,l                           ;[0132] 7d
                    cpl                                     ;[0133] 2f
                    ld        l,a                           ;[0134] 6f
                    ld        a,h                           ;[0135] 7c
                    cpl                                     ;[0136] 2f
                    ld        h,a                           ;[0137] 67
                    inc       hl                            ;[0138] 23
                    ret                                     ;[0139] c9

__modsint_callee:
                    pop       af                            ;[013a] f1
                    pop       hl                            ;[013b] e1
                    pop       de                            ;[013c] d1
                    push      af                            ;[013d] f5
                    call      l_divs_16_16x16               ;[013e] cd 44 01
                    ex        de,hl                         ;[0141] eb
                    ret                                     ;[0142] c9

                    ex        de,hl                         ;[0143] eb
l_divs_16_16x16:
                    ld        a,d                           ;[0144] 7a
                    or        e                             ;[0145] b3
                    jr        z,divide_by_zero              ;[0146] 28 1c
l0_divs_16_16x16:
                    ld        b,h                           ;[0148] 44
                    ld        c,d                           ;[0149] 4a
                    push      bc                            ;[014a] c5
                    bit       7,h                           ;[014b] cb 7c
                    call      nz,l_neg_hl                   ;[014d] c4 32 01
                    bit       7,d                           ;[0150] cb 7a
                    call      nz,l_neg_de                   ;[0152] c4 2a 01
                    call      l0_divu_16_16x16              ;[0155] cd 74 01
                    pop       bc                            ;[0158] c1
                    ld        a,b                           ;[0159] 78
                    xor       c                             ;[015a] a9
                    jp        m,l_neg_hl                    ;[015b] fa 32 01
                    bit       7,b                           ;[015e] cb 78
                    ret       z                             ;[0160] c8
                    jp        l_neg_de                      ;[0161] c3 2a 01
divide_by_zero:
                    ex        de,hl                         ;[0164] eb
                    call      error_divide_by_zero_mc       ;[0165] cd 16 01
                    ld        h,$7f                         ;[0168] 26 7f
                    bit       7,d                           ;[016a] cb 7a
                    ret       z                             ;[016c] c8
                    inc       hl                            ;[016d] 23
                    ret                                     ;[016e] c9

                    ex        de,hl                         ;[016f] eb
l_divu_16_16x16:
                    ld        a,d                           ;[0170] 7a
                    or        e                             ;[0171] b3
                    jr        z,divide_zero                 ;[0172] 28 32
l0_divu_16_16x16:
                    inc       d                             ;[0174] 14
                    dec       d                             ;[0175] 15
                    jr        z,l0_small_divu_16_16x8       ;[0176] 28 1c
divisor_sixteen_bit:
                    ld        a,l                           ;[0178] 7d
                    ld        l,h                           ;[0179] 6c
                    ld        h,$00                         ;[017a] 26 00
                    ld        b,$08                         ;[017c] 06 08
loop_16_0:
                    rla                                     ;[017e] 17
                    adc       hl,hl                         ;[017f] ed 6a
                    sbc       hl,de                         ;[0181] ed 52
                    jr        nc,loop_16_1                  ;[0183] 30 01
                    add       hl,de                         ;[0185] 19
loop_16_1:
                    ccf                                     ;[0186] 3f
                    djnz      loop_16_0                     ;[0187] 10 f5
                    rla                                     ;[0189] 17
                    ld        d,b                           ;[018a] 50
                    ld        e,a                           ;[018b] 5f
                    ex        de,hl                         ;[018c] eb
                    or        a                             ;[018d] b7
                    ret                                     ;[018e] c9

                    ex        de,hl                         ;[018f] eb
l_small_divu_16_16x8:
                    inc       e                             ;[0190] 1c
                    dec       e                             ;[0191] 1d
                    jr        z,divide_zero                 ;[0192] 28 12
l0_small_divu_16_16x8:
                    xor       a                             ;[0194] af
                    ld        d,a                           ;[0195] 57
                    ld        b,$10                         ;[0196] 06 10
loop_8_0:
                    add       hl,hl                         ;[0198] 29
                    rla                                     ;[0199] 17
                    jr        c,loop_8_2                    ;[019a] 38 03
                    cp        e                             ;[019c] bb
                    jr        c,loop_8_1                    ;[019d] 38 02
loop_8_2:
                    sub       e                             ;[019f] 93
                    inc       l                             ;[01a0] 2c
loop_8_1:
                    djnz      loop_8_0                      ;[01a1] 10 f5
                    ld        e,a                           ;[01a3] 5f
                    or        a                             ;[01a4] b7
                    ret                                     ;[01a5] c9

divide_zero:
                    ex        de,hl                         ;[01a6] eb
                    jp        error_divide_by_zero_mc       ;[01a7] c3 16 01
_strncmp_callee:
                    pop       af                            ;[01aa] f1
                    pop       de                            ;[01ab] d1
                    pop       hl                            ;[01ac] e1
                    pop       bc                            ;[01ad] c1
                    push      af                            ;[01ae] f5
                    jp        asm_strncmp                   ;[01af] c3 ca 01
asm_memcpy:
                    ld        a,b                           ;[01b2] 78
                    or        c                             ;[01b3] b1
                    jr        z,asm1_memcpy                 ;[01b4] 28 06
asm0_memcpy:
                    push      de                            ;[01b6] d5
                    ldir                                    ;[01b7] ed b0
                    pop       hl                            ;[01b9] e1
                    or        a                             ;[01ba] b7
                    ret                                     ;[01bb] c9

asm1_memcpy:
                    ld        h,d                           ;[01bc] 62
                    ld        l,e                           ;[01bd] 6b
                    ret                                     ;[01be] c9

_strlen_fastcall:
                    xor       a                             ;[01bf] af
                    ld        c,a                           ;[01c0] 4f
                    ld        b,a                           ;[01c1] 47
                    cpir                                    ;[01c2] ed b1
                    ld        hl,$ffff                      ;[01c4] 21 ff ff
                    sbc       hl,bc                         ;[01c7] ed 42
                    ret                                     ;[01c9] c9

asm_strncmp:
                    ld        a,b                           ;[01ca] 78
                    or        c                             ;[01cb] b1
                    jr        z,equal                       ;[01cc] 28 0d
loop:
                    ld        a,(de)                        ;[01ce] 1a
                    cpi                                     ;[01cf] ed a1
                    jr        nz,different                  ;[01d1] 20 0c
                    jp        po,equal                      ;[01d3] e2 db 01
                    inc       de                            ;[01d6] 13
                    or        a                             ;[01d7] b7
                    jr        nz,loop                       ;[01d8] 20 f4
                    dec       de                            ;[01da] 1b
equal:
                    ld        hl,$0000                      ;[01db] 21 00 00
                    ret                                     ;[01de] c9

different:
                    dec       hl                            ;[01df] 2b
                    sub       (hl)                          ;[01e0] 96
                    ld        h,a                           ;[01e1] 67
                    ret                                     ;[01e2] c9

asm_mtx_init:
                    ld        a,c                           ;[01e3] 79
                    and       $f8                           ;[01e4] e6 f8
                    jr        nz,unknown_type               ;[01e6] 20 15
                    ld        a,c                           ;[01e8] 79
                    and       $07                           ;[01e9] e6 07
                    jr        z,unknown_type                ;[01eb] 28 10
                    xor       a                             ;[01ed] af
                    call      $004f                         ;[01ee] cd 4f 00
                    dec       hl                            ;[01f1] 2b
                    dec       hl                            ;[01f2] 2b
                    dec       hl                            ;[01f3] 2b
                    ld        (hl),$fe                      ;[01f4] 36 fe
                    dec       hl                            ;[01f6] 2b
                    dec       hl                            ;[01f7] 2b
                    ld        (hl),c                        ;[01f8] 71
                    ld        hl,$0000                      ;[01f9] 21 00 00
                    ret                                     ;[01fc] c9

unknown_type:
                    ld        hl,$0001                      ;[01fd] 21 01 00
                    scf                                     ;[0200] 37
                    ret                                     ;[0201] c9

KERNEL_ENTRY:
                    xor       a                             ;[0202] af
                    ld        hl,$200a                      ;[0203] 21 0a 20
                    ld        (hl),a                        ;[0206] 77
                    set       0,(hl)                        ;[0207] cb c6
                    ld        ($2002),sp                    ;[0209] ed 73 02 20
                    jp        _kernel_main                  ;[020d] c3 0b 04
                    jr        _kernel_panic                 ;[0210] 18 00
_kernel_panic:
                    ld        hl,$16bb                      ;[0212] 21 bb 16
                    call      MINIMAL_PUTS                  ;[0215] cd 29 02
                    call      REG_DUMP                      ;[0218] cd 31 02
KP_LOOP:
                    jr        KP_LOOP                       ;[021b] 18 fe
exec_init_jump:
                    ld        sp,$fbff                      ;[021d] 31 ff fb
                    jp        $3000                         ;[0220] c3 00 30
exec_jump:
                    ld        sp,$efff                      ;[0223] 31 ff ef
                    jp        $4020                         ;[0226] c3 20 40
MINIMAL_PUTS:
                    ld        a,(hl)                        ;[0229] 7e
                    or        a                             ;[022a] b7
                    ret       z                             ;[022b] c8
                    out       ($81),a                       ;[022c] d3 81
                    inc       hl                            ;[022e] 23
                    jr        MINIMAL_PUTS                  ;[022f] 18 f8
REG_DUMP:
                    push      af                            ;[0231] f5
                    push      bc                            ;[0232] c5
                    push      de                            ;[0233] d5
                    push      hl                            ;[0234] e5
                    push      ix                            ;[0235] dd e5
                    push      iy                            ;[0237] fd e5
                    push      iy                            ;[0239] fd e5
                    push      ix                            ;[023b] dd e5
                    push      hl                            ;[023d] e5
                    push      de                            ;[023e] d5
                    push      bc                            ;[023f] c5
                    push      af                            ;[0240] f5
                    ld        hl,$16d6                      ;[0241] 21 d6 16
                    call      MINIMAL_PUTS                  ;[0244] cd 29 02
                    pop       hl                            ;[0247] e1
                    call      _kputh                        ;[0248] cd fd 06
                    ld        hl,$16dc                      ;[024b] 21 dc 16
                    call      MINIMAL_PUTS                  ;[024e] cd 29 02
                    pop       hl                            ;[0251] e1
                    call      _kputh                        ;[0252] cd fd 06
                    ld        hl,$16e2                      ;[0255] 21 e2 16
                    call      MINIMAL_PUTS                  ;[0258] cd 29 02
                    pop       hl                            ;[025b] e1
                    call      _kputh                        ;[025c] cd fd 06
                    ld        hl,$16e8                      ;[025f] 21 e8 16
                    call      MINIMAL_PUTS                  ;[0262] cd 29 02
                    pop       hl                            ;[0265] e1
                    call      _kputh                        ;[0266] cd fd 06
                    ld        hl,$16ee                      ;[0269] 21 ee 16
                    call      MINIMAL_PUTS                  ;[026c] cd 29 02
                    pop       hl                            ;[026f] e1
                    call      _kputh                        ;[0270] cd fd 06
                    ld        hl,$16f4                      ;[0273] 21 f4 16
                    call      MINIMAL_PUTS                  ;[0276] cd 29 02
                    pop       hl                            ;[0279] e1
                    call      _kputh                        ;[027a] cd fd 06
                    ld        hl,$16fa                      ;[027d] 21 fa 16
                    call      MINIMAL_PUTS                  ;[0280] cd 29 02
                    ld        hl,$0000                      ;[0283] 21 00 00
                    add       hl,sp                         ;[0286] 39
                    call      _kputh                        ;[0287] cd fd 06
                    pop       iy                            ;[028a] fd e1
                    pop       ix                            ;[028c] dd e1
                    pop       hl                            ;[028e] e1
                    pop       de                            ;[028f] d1
                    pop       bc                            ;[0290] c1
                    pop       af                            ;[0291] f1
                    ret                                     ;[0292] c9

STACKTRACE:
                    push      bc                            ;[0293] c5
                    push      hl                            ;[0294] e5
                    ld        hl,$16c9                      ;[0295] 21 c9 16
                    call      MINIMAL_PUTS                  ;[0298] cd 29 02
                    ld        hl,$0000                      ;[029b] 21 00 00
                    add       hl,sp                         ;[029e] 39
ST_LOOP:
                    ld        e,(hl)                        ;[029f] 5e
                    inc       hl                            ;[02a0] 23
                    ld        d,(hl)                        ;[02a1] 56
                    inc       hl                            ;[02a2] 23
                    ex        de,hl                         ;[02a3] eb
                    push      bc                            ;[02a4] c5
                    push      hl                            ;[02a5] e5
                    call      _kputh                        ;[02a6] cd fd 06
                    ex        de,hl                         ;[02a9] eb
                    ld        a,$20                         ;[02aa] 3e 20
                    rst       $08                           ;[02ac] cf
                    pop       hl                            ;[02ad] e1
                    pop       bc                            ;[02ae] c1
                    dec       c                             ;[02af] 0d
                    jr        nz,ST_LOOP                    ;[02b0] 20 ed
                    pop       hl                            ;[02b2] e1
                    pop       bc                            ;[02b3] c1
                    ret                                     ;[02b4] c9

SYSCALL_DISPATCH:
                    ld        ($2014),sp                    ;[02b5] ed 73 14 20
                    ld        sp,($2002)                    ;[02b9] ed 7b 02 20
                    push      hl                            ;[02bd] e5
                    push      af                            ;[02be] f5
                    ld        l,a                           ;[02bf] 6f
                    ld        a,$0c                         ;[02c0] 3e 0c
                    cp        l                             ;[02c2] bd
                    jp        c,INVALID_SYSCALL             ;[02c3] da e2 02
                    pop       af                            ;[02c6] f1
                    pop       hl                            ;[02c7] e1
                    push      af                            ;[02c8] f5
                    push      bc                            ;[02c9] c5
                    push      de                            ;[02ca] d5
                    push      hl                            ;[02cb] e5
                    ld        ($200e),hl                    ;[02cc] 22 0e 20
                    push      de                            ;[02cf] d5
                    ld        hl,$02f4                      ;[02d0] 21 f4 02
                    sla       a                             ;[02d3] cb 27
                    ld        d,$00                         ;[02d5] 16 00
                    ld        e,a                           ;[02d7] 5f
                    add       hl,de                         ;[02d8] 19
                    ld        e,(hl)                        ;[02d9] 5e
                    inc       hl                            ;[02da] 23
                    ld        d,(hl)                        ;[02db] 56
                    ld        hl,$0000                      ;[02dc] 21 00 00
                    add       hl,de                         ;[02df] 19
                    pop       de                            ;[02e0] d1
                    jp        (hl)                          ;[02e1] e9
INVALID_SYSCALL:
                    pop       af                            ;[02e2] f1
                    pop       hl                            ;[02e3] e1
                    ld        hl,$0002                      ;[02e4] 21 02 00
                    ld        sp,($2014)                    ;[02e7] ed 7b 14 20
                    ret                                     ;[02eb] c9

GET_HL_SYSCALL:
                    ld        hl,($200e)                    ;[02ec] 2a 0e 20
                    ret                                     ;[02ef] c9

SAVE_RET:
                    ld        ($2008),hl                    ;[02f0] 22 08 20
                    ret                                     ;[02f3] c9

SYSCALL_TABLE:
                    daa                                     ;[02f4] 27
                    inc       bc                            ;[02f5] 03
                    ld        (hl),$03                      ;[02f6] 36 03
                    ld        c,b                           ;[02f8] 48
                    inc       bc                            ;[02f9] 03
                    ld        e,d                           ;[02fa] 5a
                    inc       bc                            ;[02fb] 03
                    add       h                             ;[02fc] 84
                    inc       bc                            ;[02fd] 03
                    sub       h                             ;[02fe] 94
                    inc       bc                            ;[02ff] 03
                    sbc       l                             ;[0300] 9d
                    inc       bc                            ;[0301] 03
                    xor       h                             ;[0302] ac
                    inc       bc                            ;[0303] 03
                    cp        c                             ;[0304] b9
                    inc       bc                            ;[0305] 03
                    ret                                     ;[0306] c9

                    inc       bc                            ;[0307] 03
                    push      de                            ;[0308] d5
                    inc       bc                            ;[0309] 03
                    push      hl                            ;[030a] e5
                    inc       bc                            ;[030b] 03
SYSCALL_END:
                    pop       hl                            ;[030c] e1
                    pop       de                            ;[030d] d1
                    pop       bc                            ;[030e] c1
                    pop       af                            ;[030f] f1
                    ld        hl,($2008)                    ;[0310] 2a 08 20
SYSCALL_END_SKIP:
                    ld        ($2002),sp                    ;[0313] ed 73 02 20
                    ld        sp,($2014)                    ;[0317] ed 7b 14 20
                    ret                                     ;[031b] c9

ECHO_CHAR:
                    push      hl                            ;[031c] e5
                    ld        hl,$200a                      ;[031d] 21 0a 20
                    bit       0,(hl)                        ;[0320] cb 46
                    pop       hl                            ;[0322] e1
                    jr        z,SKIP_ECHO                   ;[0323] 28 01
                    rst       $08                           ;[0325] cf
SKIP_ECHO:
                    ret                                     ;[0326] c9

SYS_EXIT:
                    ld        hl,($2006)                    ;[0327] 2a 06 20
                    ld        ($2014),hl                    ;[032a] 22 14 20
                    call      GET_HL_SYSCALL                ;[032d] cd ec 02
                    call      SAVE_RET                      ;[0330] cd f0 02
                    jp        SYSCALL_END                   ;[0333] c3 0c 03
SYS_WRITE:
                    call      GET_HL_SYSCALL                ;[0336] cd ec 02
                    push      bc                            ;[0339] c5
                    push      de                            ;[033a] d5
                    push      hl                            ;[033b] e5
                    call      _sysc_write                   ;[033c] cd 89 05
                    call      SAVE_RET                      ;[033f] cd f0 02
                    pop       hl                            ;[0342] e1
                    pop       de                            ;[0343] d1
                    pop       bc                            ;[0344] c1
                    jp        SYSCALL_END                   ;[0345] c3 0c 03
SYS_READ:
                    call      GET_HL_SYSCALL                ;[0348] cd ec 02
                    push      bc                            ;[034b] c5
                    push      de                            ;[034c] d5
                    push      hl                            ;[034d] e5
                    call      _sysc_read                    ;[034e] cd f0 05
                    call      SAVE_RET                      ;[0351] cd f0 02
                    pop       hl                            ;[0354] e1
                    pop       de                            ;[0355] d1
                    pop       bc                            ;[0356] c1
                    jp        SYSCALL_END                   ;[0357] c3 0c 03
SYS_GETS:
                    call      GET_HL_SYSCALL                ;[035a] cd ec 02
SYS_GETS_LOOP:
                    rst       $10                           ;[035d] d7
                    call      ECHO_CHAR                     ;[035e] cd 1c 03
                    cp        $0d                           ;[0361] fe 0d
                    jr        z,SYS_GETS_END                ;[0363] 28 1c
                    cp        $0a                           ;[0365] fe 0a
                    jr        z,SYS_GETS_END                ;[0367] 28 18
                    ld        (hl),a                        ;[0369] 77
                    inc       hl                            ;[036a] 23
                    cp        $7f                           ;[036b] fe 7f
                    jr        z,SYS_GETS_BCKSP              ;[036d] 28 0b
                    cp        $08                           ;[036f] fe 08
                    jr        z,SYS_GETS_BCKSP              ;[0371] 28 07
                    xor       a                             ;[0373] af
                    dec       de                            ;[0374] 1b
                    cp        e                             ;[0375] bb
                    jr        z,SYS_GETS_END                ;[0376] 28 09
                    jr        SYS_GETS_LOOP                 ;[0378] 18 e3
SYS_GETS_BCKSP:
                    dec       hl                            ;[037a] 2b
                    dec       hl                            ;[037b] 2b
                    ld        (hl),$00                      ;[037c] 36 00
                    inc       de                            ;[037e] 13
                    jr        SYS_GETS_LOOP                 ;[037f] 18 dc
SYS_GETS_END:
                    jp        SYSCALL_END                   ;[0381] c3 0c 03
SYS_PUTS:
                    call      GET_HL_SYSCALL                ;[0384] cd ec 02
SYS_PUTS_LOOP:
                    ld        a,(hl)                        ;[0387] 7e
                    rst       $08                           ;[0388] cf
                    inc       hl                            ;[0389] 23
                    xor       a                             ;[038a] af
                    dec       de                            ;[038b] 1b
                    cp        e                             ;[038c] bb
                    jr        z,SYS_PUTS_END                ;[038d] 28 02
                    jr        SYS_PUTS_LOOP                 ;[038f] 18 f6
SYS_PUTS_END:
                    jp        SYSCALL_END                   ;[0391] c3 0c 03
SYS_PUTH:
                    call      GET_HL_SYSCALL                ;[0394] cd ec 02
                    call      _kputh                        ;[0397] cd fd 06
                    jp        SYSCALL_END                   ;[039a] c3 0c 03
SYS_GETINFO:
                    call      GET_HL_SYSCALL                ;[039d] cd ec 02
                    ex        de,hl                         ;[03a0] eb
                    ld        hl,$1700                      ;[03a1] 21 00 17
                    ld        bc,$002d                      ;[03a4] 01 2d 00
                    ldir                                    ;[03a7] ed b0
                    jp        SYSCALL_END                   ;[03a9] c3 0c 03
SYS_RAND:
                    ld        a,r                           ;[03ac] ed 5f
                    ld        l,a                           ;[03ae] 6f
                    ld        a,r                           ;[03af] ed 5f
                    xor       l                             ;[03b1] ad
                    ld        h,a                           ;[03b2] 67
                    call      SAVE_RET                      ;[03b3] cd f0 02
                    jp        SYSCALL_END                   ;[03b6] c3 0c 03
SYS_OPEN:
                    call      GET_HL_SYSCALL                ;[03b9] cd ec 02
                    push      de                            ;[03bc] d5
                    push      hl                            ;[03bd] e5
                    call      _fd_create                    ;[03be] cd a8 14
                    pop       de                            ;[03c1] d1
                    pop       de                            ;[03c2] d1
                    call      SAVE_RET                      ;[03c3] cd f0 02
                    jp        SYSCALL_END                   ;[03c6] c3 0c 03
SYS_CLOSE:
                    call      GET_HL_SYSCALL                ;[03c9] cd ec 02
                    call      _fd_close                     ;[03cc] cd 4b 14
                    call      SAVE_RET                      ;[03cf] cd f0 02
                    jp        SYSCALL_END                   ;[03d2] c3 0c 03
SYS_SEEK:
                    call      GET_HL_SYSCALL                ;[03d5] cd ec 02
                    push      de                            ;[03d8] d5
                    push      hl                            ;[03d9] e5
                    call      _mfs_seek                     ;[03da] cd 16 12
                    pop       de                            ;[03dd] d1
                    pop       de                            ;[03de] d1
                    call      SAVE_RET                      ;[03df] cd f0 02
                    jp        SYSCALL_END                   ;[03e2] c3 0c 03
SYS_EXEC:
                    ld        hl,($2014)                    ;[03e5] 2a 14 20
                    ld        ($2006),hl                    ;[03e8] 22 06 20
                    call      GET_HL_SYSCALL                ;[03eb] cd ec 02
                    push      de                            ;[03ee] d5
                    push      hl                            ;[03ef] e5
                    call      _exec                         ;[03f0] cd 63 04
                    call      SAVE_RET                      ;[03f3] cd f0 02
                    pop       de                            ;[03f6] d1
                    pop       de                            ;[03f7] d1
                    ld        ($200e),sp                    ;[03f8] ed 73 0e 20
                    ld        hl,$efff                      ;[03fc] 21 ff ef
                    ld        sp,hl                         ;[03ff] f9
                    ld        hl,$4020                      ;[0400] 21 20 40
                    push      hl                            ;[0403] e5
                    ld        sp,($200e)                    ;[0404] ed 7b 0e 20
                    jp        SYSCALL_END                   ;[0408] c3 0c 03
_kernel_main:
                    call      _tty_init                     ;[040b] cd 4c 07
                    ei                                      ;[040e] fb
                    im        1                             ;[040f] ed 56
                    ld        hl,$14d5                      ;[0411] 21 d5 14
                    call      _kputs                        ;[0414] cd 5c 06
                    call      _mfs_init                     ;[0417] cd 92 08
                    ld        a,l                           ;[041a] 7d
                    and       h                             ;[041b] a4
                    inc       a                             ;[041c] 3c
                    jr        nz,l_kernel_main_00102        ;[041d] 20 09
                    ld        hl,$14e3                      ;[041f] 21 e3 14
                    call      _kputs                        ;[0422] cd 5c 06
                    call      _kernel_panic                 ;[0425] cd 12 02
l_kernel_main_00102:
                    ld        hl,$14fc                      ;[0428] 21 fc 14
                    call      _kputs                        ;[042b] cd 5c 06
                    call      _fd_init                      ;[042e] cd b5 13
                    ld        a,l                           ;[0431] 7d
                    and       h                             ;[0432] a4
                    inc       a                             ;[0433] 3c
                    jr        nz,l_kernel_main_00104        ;[0434] 20 09
                    ld        hl,$150b                      ;[0436] 21 0b 15
                    call      _kputs                        ;[0439] cd 5c 06
                    call      _kernel_panic                 ;[043c] cd 12 02
l_kernel_main_00104:
                    ld        hl,$1529                      ;[043f] 21 29 15
                    call      _kputs                        ;[0442] cd 5c 06
                    ld        hl,$1538                      ;[0445] 21 38 15
                    call      _kputs                        ;[0448] cd 5c 06
                    ld        hl,$154d                      ;[044b] 21 4d 15
                    call      _exec_init                    ;[044e] cd 1d 05
                    ld        a,l                           ;[0451] 7d
                    and       h                             ;[0452] a4
                    inc       a                             ;[0453] 3c
                    jr        nz,l_kernel_main_00106        ;[0454] 20 06
                    ld        hl,$1555                      ;[0456] 21 55 15
                    call      _kputs                        ;[0459] cd 5c 06
l_kernel_main_00106:
                    call      _kernel_panic                 ;[045c] cd 12 02
                    ld        hl,$0000                      ;[045f] 21 00 00
                    ret                                     ;[0462] c9

_exec:
                    push      ix                            ;[0463] dd e5
                    ld        ix,$0000                      ;[0465] dd 21 00 00
                    add       ix,sp                         ;[0469] dd 39
                    ld        hl,$0004                      ;[046b] 21 04 00
                    push      hl                            ;[046e] e5
                    ld        l,(ix+$04)                    ;[046f] dd 6e 04
                    ld        h,(ix+$05)                    ;[0472] dd 66 05
                    push      hl                            ;[0475] e5
                    call      _mfs_open                     ;[0476] cd 97 0f
                    pop       af                            ;[0479] f1
                    pop       af                            ;[047a] f1
                    ex        de,hl                         ;[047b] eb
                    ld        a,e                           ;[047c] 7b
                    and       d                             ;[047d] a2
                    inc       a                             ;[047e] 3c
                    jr        nz,l_exec_00102               ;[047f] 20 0c
                    ld        hl,$1569                      ;[0481] 21 69 15
                    call      _kputs                        ;[0484] cd 5c 06
                    ld        hl,$ffff                      ;[0487] 21 ff ff
                    jp        l_exec_00111                  ;[048a] c3 1a 05
l_exec_00102:
                    ld        bc,$2a8e                      ;[048d] 01 8e 2a
                    ld        l,e                           ;[0490] 6b
                    ld        h,d                           ;[0491] 62
                    add       hl,hl                         ;[0492] 29
                    add       hl,de                         ;[0493] 19
                    add       hl,hl                         ;[0494] 29
                    add       hl,bc                         ;[0495] 09
                    ld        bc,(_pih)                     ;[0496] ed 4b 4e 17
                    inc       bc                            ;[049a] 03
                    inc       bc                            ;[049b] 03
                    ld        de,$0004                      ;[049c] 11 04 00
                    add       hl,de                         ;[049f] 19
                    ld        e,(hl)                        ;[04a0] 5e
                    inc       hl                            ;[04a1] 23
                    ld        d,(hl)                        ;[04a2] 56
                    ld        hl,$000a                      ;[04a3] 21 0a 00
                    add       hl,de                         ;[04a6] 19
                    ld        a,(hl)                        ;[04a7] 7e
                    inc       hl                            ;[04a8] 23
                    ld        d,(hl)                        ;[04a9] 56
                    ld        (bc),a                        ;[04aa] 02
                    inc       bc                            ;[04ab] 03
                    ld        a,d                           ;[04ac] 7a
                    ld        (bc),a                        ;[04ad] 02
                    ld        l,(ix+$06)                    ;[04ae] dd 6e 06
                    ld        h,(ix+$07)                    ;[04b1] dd 66 07
                    call      _strlen_fastcall              ;[04b4] cd bf 01
                    ld        e,(ix+$06)                    ;[04b7] dd 5e 06
                    ld        d,(ix+$07)                    ;[04ba] dd 56 07
                    ld        a,l                           ;[04bd] 7d
                    sub       $10                           ;[04be] d6 10
                    ld        a,h                           ;[04c0] 7c
                    sbc       $00                           ;[04c1] de 00
                    jr        nc,l_exec_00109               ;[04c3] 30 1d
                    ld        hl,(_pih)                     ;[04c5] 2a 4e 17
                    ld        bc,$0010                      ;[04c8] 01 10 00
                    add       hl,bc                         ;[04cb] 09
                    push      hl                            ;[04cc] e5
                    ld        l,(ix+$06)                    ;[04cd] dd 6e 06
                    ld        h,(ix+$07)                    ;[04d0] dd 66 07
                    call      _strlen_fastcall              ;[04d3] cd bf 01
                    ld        c,l                           ;[04d6] 4d
                    ld        b,h                           ;[04d7] 44
                    pop       hl                            ;[04d8] e1
                    ld        a,b                           ;[04d9] 78
                    ex        de,hl                         ;[04da] eb
                    or        c                             ;[04db] b1
                    jr        z,l_exec_00110                ;[04dc] 28 39
                    ldir                                    ;[04de] ed b0
                    jr        l_exec_00110                  ;[04e0] 18 35
l_exec_00109:
                    ld        l,(ix+$06)                    ;[04e2] dd 6e 06
                    ld        h,(ix+$07)                    ;[04e5] dd 66 07
                    call      _strlen_fastcall              ;[04e8] cd bf 01
                    ld        c,l                           ;[04eb] 4d
                    ld        b,h                           ;[04ec] 44
                    ld        hl,(_pih)                     ;[04ed] 2a 4e 17
                    ld        a,$10                         ;[04f0] 3e 10
                    add       l                             ;[04f2] 85
                    ld        l,a                           ;[04f3] 6f
                    ld        a,$00                         ;[04f4] 3e 00
                    adc       h                             ;[04f6] 8c
                    ld        h,a                           ;[04f7] 67
                    ld        a,$10                         ;[04f8] 3e 10
                    cp        c                             ;[04fa] b9
                    ld        a,$00                         ;[04fb] 3e 00
                    sbc       b                             ;[04fd] 98
                    jr        nc,l_exec_00106               ;[04fe] 30 08
                    ex        de,hl                         ;[0500] eb
                    ld        bc,$0010                      ;[0501] 01 10 00
                    ldir                                    ;[0504] ed b0
                    jr        l_exec_00110                  ;[0506] 18 0f
l_exec_00106:
                    ld        a,(ix+$07)                    ;[0508] dd 7e 07
                    or        (ix+$06)                      ;[050b] dd b6 06
                    jr        nz,l_exec_00110               ;[050e] 20 07
                    ld        b,$10                         ;[0510] 06 10
l_exec_00144:
                    ld        (hl),$00                      ;[0512] 36 00
                    inc       hl                            ;[0514] 23
                    djnz      l_exec_00144                  ;[0515] 10 fb
l_exec_00110:
                    ld        hl,$0000                      ;[0517] 21 00 00
l_exec_00111:
                    pop       ix                            ;[051a] dd e1
                    ret                                     ;[051c] c9

_exec_init:
                    ld        de,$0008                      ;[051d] 11 08 00
                    push      de                            ;[0520] d5
                    push      hl                            ;[0521] e5
                    call      _mfs_open                     ;[0522] cd 97 0f
                    pop       af                            ;[0525] f1
                    pop       af                            ;[0526] f1
                    ex        de,hl                         ;[0527] eb
                    ld        a,e                           ;[0528] 7b
                    and       d                             ;[0529] a2
                    inc       a                             ;[052a] 3c
                    jr        nz,l_exec_init_00102          ;[052b] 20 06
                    ld        hl,$ffff                      ;[052d] 21 ff ff
                    jp        l_exec_init_00103             ;[0530] c3 64 05
l_exec_init_00102:
                    push      de                            ;[0533] d5
                    ld        l,e                           ;[0534] 6b
                    ld        h,d                           ;[0535] 62
                    add       hl,hl                         ;[0536] 29
                    add       hl,de                         ;[0537] 19
                    add       hl,hl                         ;[0538] 29
                    pop       de                            ;[0539] d1
                    ld        bc,$2a8e                      ;[053a] 01 8e 2a
                    add       hl,bc                         ;[053d] 09
                    ld        bc,$0004                      ;[053e] 01 04 00
                    add       hl,bc                         ;[0541] 09
                    ld        c,(hl)                        ;[0542] 4e
                    inc       hl                            ;[0543] 23
                    ld        b,(hl)                        ;[0544] 46
                    ld        hl,$000a                      ;[0545] 21 0a 00
                    add       hl,bc                         ;[0548] 09
                    ld        c,(hl)                        ;[0549] 4e
                    inc       hl                            ;[054a] 23
                    ld        b,(hl)                        ;[054b] 46
                    push      de                            ;[054c] d5
                    ld        de,$3000                      ;[054d] 11 00 30
                    ld        a,b                           ;[0550] 78
                    or        c                             ;[0551] b1
                    ld        hl,$4020                      ;[0552] 21 20 40
                    jr        z,l_exec_init_00114           ;[0555] 28 02
                    ldir                                    ;[0557] ed b0
l_exec_init_00114:
                    pop       de                            ;[0559] d1
                    ex        de,hl                         ;[055a] eb
                    call      _mfs_close                    ;[055b] cd d4 10
                    jp        exec_init_jump                ;[055e] c3 1d 02
                    ld        hl,$0000                      ;[0561] 21 00 00
l_exec_init_00103:
                    ret                                     ;[0564] c9

_ksyscall:
                    push      ix                            ;[0565] dd e5
                    ld        ix,$0000                      ;[0567] dd 21 00 00
                    add       ix,sp                         ;[056b] dd 39
                    ld        a,(ix+$04)                    ;[056d] dd 7e 04
                    ld        l,(ix+$05)                    ;[0570] dd 6e 05
                    ld        h,(ix+$06)                    ;[0573] dd 66 06
                    ld        e,(ix+$07)                    ;[0576] dd 5e 07
                    ld        d,(ix+$08)                    ;[0579] dd 56 08
                    ld        c,(ix+$09)                    ;[057c] dd 4e 09
                    ld        b,(ix+$0a)                    ;[057f] dd 46 0a
                    rst       $20                           ;[0582] e7
                    pop       ix                            ;[0583] dd e1
                    ret                                     ;[0585] c9

                    ld        hl,$0000                      ;[0586] 21 00 00
_sysc_write:
                    push      ix                            ;[0589] dd e5
                    ld        ix,$0000                      ;[058b] dd 21 00 00
                    add       ix,sp                         ;[058f] dd 39
                    ld        bc,$2a8e                      ;[0591] 01 8e 2a
                    ld        l,(ix+$04)                    ;[0594] dd 6e 04
                    ld        h,(ix+$05)                    ;[0597] dd 66 05
                    ld        e,l                           ;[059a] 5d
                    ld        d,h                           ;[059b] 54
                    add       hl,hl                         ;[059c] 29
                    add       hl,de                         ;[059d] 19
                    add       hl,hl                         ;[059e] 29
                    add       hl,bc                         ;[059f] 09
                    ld        a,(ix+$04)                    ;[05a0] dd 7e 04
                    and       (ix+$05)                      ;[05a3] dd a6 05
                    inc       a                             ;[05a6] 3c
                    jr        nz,l_sysc_write_00102         ;[05a7] 20 05
                    ld        hl,$ffff                      ;[05a9] 21 ff ff
                    jr        l_sysc_write_00107            ;[05ac] 18 3f
l_sysc_write_00102:
                    ld        a,(hl)                        ;[05ae] 7e
                    cp        $02                           ;[05af] fe 02
                    jr        z,l_sysc_write_00103          ;[05b1] 28 04
                    sub       $03                           ;[05b3] d6 03
                    jr        nz,l_sysc_write_00104         ;[05b5] 20 15
l_sysc_write_00103:
                    ld        l,(ix+$06)                    ;[05b7] dd 6e 06
                    ld        h,(ix+$07)                    ;[05ba] dd 66 07
                    push      hl                            ;[05bd] e5
                    ld        l,(ix+$08)                    ;[05be] dd 6e 08
                    ld        h,(ix+$09)                    ;[05c1] dd 66 09
                    push      hl                            ;[05c4] e5
                    call      _kputslen                     ;[05c5] cd 6d 06
                    pop       af                            ;[05c8] f1
                    pop       af                            ;[05c9] f1
                    jr        l_sysc_write_00105            ;[05ca] 18 1b
l_sysc_write_00104:
                    ld        l,(ix+$06)                    ;[05cc] dd 6e 06
                    ld        h,(ix+$07)                    ;[05cf] dd 66 07
                    push      hl                            ;[05d2] e5
                    ld        l,(ix+$08)                    ;[05d3] dd 6e 08
                    ld        h,(ix+$09)                    ;[05d6] dd 66 09
                    push      hl                            ;[05d9] e5
                    ld        l,(ix+$04)                    ;[05da] dd 6e 04
                    ld        h,(ix+$05)                    ;[05dd] dd 66 05
                    push      hl                            ;[05e0] e5
                    call      _mfs_write                    ;[05e1] cd 71 11
                    pop       af                            ;[05e4] f1
                    pop       af                            ;[05e5] f1
                    pop       af                            ;[05e6] f1
l_sysc_write_00105:
                    ld        l,(ix+$06)                    ;[05e7] dd 6e 06
                    ld        h,(ix+$07)                    ;[05ea] dd 66 07
l_sysc_write_00107:
                    pop       ix                            ;[05ed] dd e1
                    ret                                     ;[05ef] c9

_sysc_read:
                    push      ix                            ;[05f0] dd e5
                    ld        ix,$0000                      ;[05f2] dd 21 00 00
                    add       ix,sp                         ;[05f6] dd 39
                    ld        bc,$2a8e                      ;[05f8] 01 8e 2a
                    ld        l,(ix+$04)                    ;[05fb] dd 6e 04
                    ld        h,(ix+$05)                    ;[05fe] dd 66 05
                    ld        e,l                           ;[0601] 5d
                    ld        d,h                           ;[0602] 54
                    add       hl,hl                         ;[0603] 29
                    add       hl,de                         ;[0604] 19
                    add       hl,hl                         ;[0605] 29
                    add       hl,bc                         ;[0606] 09
                    ld        a,(ix+$04)                    ;[0607] dd 7e 04
                    and       (ix+$05)                      ;[060a] dd a6 05
                    inc       a                             ;[060d] 3c
                    jr        nz,l_sysc_read_00102          ;[060e] 20 05
                    ld        hl,$ffff                      ;[0610] 21 ff ff
                    jr        l_sysc_read_00106             ;[0613] 18 3a
l_sysc_read_00102:
                    ld        a,(hl)                        ;[0615] 7e
                    dec       a                             ;[0616] 3d
                    jr        nz,l_sysc_read_00104          ;[0617] 20 15
                    ld        l,(ix+$06)                    ;[0619] dd 6e 06
                    ld        h,(ix+$07)                    ;[061c] dd 66 07
                    push      hl                            ;[061f] e5
                    ld        l,(ix+$08)                    ;[0620] dd 6e 08
                    ld        h,(ix+$09)                    ;[0623] dd 66 09
                    push      hl                            ;[0626] e5
                    call      _kgetslen                     ;[0627] cd 9b 06
                    pop       af                            ;[062a] f1
                    pop       af                            ;[062b] f1
                    jr        l_sysc_read_00105             ;[062c] 18 1b
l_sysc_read_00104:
                    ld        l,(ix+$06)                    ;[062e] dd 6e 06
                    ld        h,(ix+$07)                    ;[0631] dd 66 07
                    push      hl                            ;[0634] e5
                    ld        l,(ix+$08)                    ;[0635] dd 6e 08
                    ld        h,(ix+$09)                    ;[0638] dd 66 09
                    push      hl                            ;[063b] e5
                    ld        l,(ix+$04)                    ;[063c] dd 6e 04
                    ld        h,(ix+$05)                    ;[063f] dd 66 05
                    push      hl                            ;[0642] e5
                    call      _mfs_read                     ;[0643] cd 06 11
                    pop       af                            ;[0646] f1
                    pop       af                            ;[0647] f1
                    pop       af                            ;[0648] f1
l_sysc_read_00105:
                    ld        l,(ix+$06)                    ;[0649] dd 6e 06
                    ld        h,(ix+$07)                    ;[064c] dd 66 07
l_sysc_read_00106:
                    pop       ix                            ;[064f] dd e1
                    ret                                     ;[0651] c9

                    ret                                     ;[0652] c9

_kgetchar:
                    rst       $10                           ;[0653] d7
                    ld        l,a                           ;[0654] 6f
                    ld        h,$00                         ;[0655] 26 00
                    ret                                     ;[0657] c9

                    ld        hl,$0000                      ;[0658] 21 00 00
                    ret                                     ;[065b] c9

_kputs:
                    ld        a,(hl)                        ;[065c] 7e
                    or        a                             ;[065d] b7
                    jr        z,l_kputs_00103               ;[065e] 28 09
                    push      hl                            ;[0660] e5
                    ld        l,a                           ;[0661] 6f
                    call      _kputchar                     ;[0662] cd 8b 08
                    pop       hl                            ;[0665] e1
                    inc       hl                            ;[0666] 23
                    jr        _kputs                        ;[0667] 18 f3
l_kputs_00103:
                    ld        hl,$0000                      ;[0669] 21 00 00
                    ret                                     ;[066c] c9

_kputslen:
                    push      ix                            ;[066d] dd e5
                    ld        ix,$0000                      ;[066f] dd 21 00 00
                    add       ix,sp                         ;[0673] dd 39
                    ld        bc,$0000                      ;[0675] 01 00 00
l_kputslen_00103:
                    ld        l,c                           ;[0678] 69
                    ld        h,b                           ;[0679] 60
                    ld        e,(ix+$06)                    ;[067a] dd 5e 06
                    ld        d,(ix+$07)                    ;[067d] dd 56 07
                    xor       a                             ;[0680] af
                    sbc       hl,de                         ;[0681] ed 52
                    jr        nc,l_kputslen_00101           ;[0683] 30 10
                    ld        l,(ix+$04)                    ;[0685] dd 6e 04
                    ld        h,(ix+$05)                    ;[0688] dd 66 05
                    add       hl,bc                         ;[068b] 09
                    ld        l,(hl)                        ;[068c] 6e
                    push      bc                            ;[068d] c5
                    call      _kputchar                     ;[068e] cd 8b 08
                    pop       bc                            ;[0691] c1
                    inc       bc                            ;[0692] 03
                    jr        l_kputslen_00103              ;[0693] 18 e3
l_kputslen_00101:
                    ld        hl,$0000                      ;[0695] 21 00 00
                    pop       ix                            ;[0698] dd e1
                    ret                                     ;[069a] c9

_kgetslen:
                    push      ix                            ;[069b] dd e5
                    ld        ix,$0000                      ;[069d] dd 21 00 00
                    add       ix,sp                         ;[06a1] dd 39
                    push      af                            ;[06a3] f5
                    ld        bc,$0000                      ;[06a4] 01 00 00
l_kgetslen_00112:
                    ld        e,c                           ;[06a7] 59
                    ld        d,b                           ;[06a8] 50
                    ld        l,(ix+$06)                    ;[06a9] dd 6e 06
                    ld        h,(ix+$07)                    ;[06ac] dd 66 07
                    ld        a,e                           ;[06af] 7b
                    sub       l                             ;[06b0] 95
                    ld        a,d                           ;[06b1] 7a
                    sbc       h                             ;[06b2] 9c
                    jr        nc,l_kgetslen_00110           ;[06b3] 30 40
                    ld        l,(ix+$04)                    ;[06b5] dd 6e 04
                    ld        h,(ix+$05)                    ;[06b8] dd 66 05
                    add       hl,bc                         ;[06bb] 09
                    push      hl                            ;[06bc] e5
                    push      bc                            ;[06bd] c5
                    push      de                            ;[06be] d5
                    call      _kgetchar                     ;[06bf] cd 53 06
                    ld        (ix-$02),l                    ;[06c2] dd 75 fe
                    ld        (ix-$01),h                    ;[06c5] dd 74 ff
                    pop       de                            ;[06c8] d1
                    pop       bc                            ;[06c9] c1
                    pop       hl                            ;[06ca] e1
                    ld        a,(ix-$02)                    ;[06cb] dd 7e fe
                    ld        (hl),a                        ;[06ce] 77
                    sub       $0d                           ;[06cf] d6 0d
                    jr        z,l_kgetslen_00110            ;[06d1] 28 22
                    ld        a,(hl)                        ;[06d3] 7e
                    cp        $0a                           ;[06d4] fe 0a
                    jr        z,l_kgetslen_00110            ;[06d6] 28 1d
                    cp        $08                           ;[06d8] fe 08
                    jr        z,l_kgetslen_00107            ;[06da] 28 04
                    sub       $7f                           ;[06dc] d6 7f
                    jr        nz,l_kgetslen_00113           ;[06de] 20 12
l_kgetslen_00107:
                    ld        a,b                           ;[06e0] 78
                    or        c                             ;[06e1] b1
                    jr        z,l_kgetslen_00105            ;[06e2] 28 0d
                    ld        (hl),$00                      ;[06e4] 36 00
                    dec       de                            ;[06e6] 1b
                    dec       de                            ;[06e7] 1b
                    push      de                            ;[06e8] d5
                    ld        l,$08                         ;[06e9] 2e 08
                    call      _kputchar                     ;[06eb] cd 8b 08
                    pop       bc                            ;[06ee] c1
                    jr        l_kgetslen_00113              ;[06ef] 18 01
l_kgetslen_00105:
                    dec       bc                            ;[06f1] 0b
l_kgetslen_00113:
                    inc       bc                            ;[06f2] 03
                    jr        l_kgetslen_00112              ;[06f3] 18 b2
l_kgetslen_00110:
                    ld        sp,ix                         ;[06f5] dd f9
                    ld        hl,$0000                      ;[06f7] 21 00 00
                    pop       ix                            ;[06fa] dd e1
                    ret                                     ;[06fc] c9

_kputh:
                    push      ix                            ;[06fd] dd e5
                    ld        ix,$0000                      ;[06ff] dd 21 00 00
                    add       ix,sp                         ;[0703] dd 39
                    dec       sp                            ;[0705] 3b
                    ld        bc,$0c00                      ;[0706] 01 00 0c
l_kputh_00107:
                    ld        (ix-$01),b                    ;[0709] dd 70 ff
                    bit       7,b                           ;[070c] cb 78
                    jr        nz,l_kputh_00109              ;[070e] 20 38
                    ld        a,b                           ;[0710] 78
                    push      af                            ;[0711] f5
                    ld        e,l                           ;[0712] 5d
                    ld        d,h                           ;[0713] 54
                    pop       af                            ;[0714] f1
                    inc       a                             ;[0715] 3c
                    jr        l_kputh_00149                 ;[0716] 18 04
l_kputh_00148:
                    sra       d                             ;[0718] cb 2a
                    rr        e                             ;[071a] cb 1b
l_kputh_00149:
                    dec       a                             ;[071c] 3d
                    jr        nz,l_kputh_00148              ;[071d] 20 f9
                    ld        a,e                           ;[071f] 7b
                    and       $0f                           ;[0720] e6 0f
                    jr        nz,l_kputh_00101              ;[0722] 20 07
                    inc       c                             ;[0724] 0c
                    dec       c                             ;[0725] 0d
                    jr        nz,l_kputh_00101              ;[0726] 20 03
                    inc       b                             ;[0728] 04
                    djnz      l_kputh_00108                 ;[0729] 10 15
l_kputh_00101:
                    ld        e,a                           ;[072b] 5f
                    sub       $0a                           ;[072c] d6 0a
                    jr        nc,l_kputh_00111              ;[072e] 30 05
                    ld        a,e                           ;[0730] 7b
                    add       $30                           ;[0731] c6 30
                    jr        l_kputh_00112                 ;[0733] 18 03
l_kputh_00111:
                    ld        a,e                           ;[0735] 7b
                    add       $37                           ;[0736] c6 37
l_kputh_00112:
                    push      hl                            ;[0738] e5
                    ld        l,a                           ;[0739] 6f
                    call      _kputchar                     ;[073a] cd 8b 08
                    pop       hl                            ;[073d] e1
                    ld        c,$01                         ;[073e] 0e 01
l_kputh_00108:
                    ld        a,(ix-$01)                    ;[0740] dd 7e ff
                    add       $fc                           ;[0743] c6 fc
                    ld        b,a                           ;[0745] 47
                    jr        l_kputh_00107                 ;[0746] 18 c1
l_kputh_00109:
                    inc       sp                            ;[0748] 33
                    pop       ix                            ;[0749] dd e1
                    ret                                     ;[074b] c9

_tty_init:
                    ld        a,$03                         ;[074c] 3e 03
                    out       ($80),a                       ;[074e] d3 80
                    ld        a,$96                         ;[0750] 3e 96
                    out       ($80),a                       ;[0752] d3 80
                    ld        hl,$2230                      ;[0754] 21 30 22
                    ld        (_tty_buffer_tail),hl         ;[0757] 22 86 2a
                    ld        hl,$2232                      ;[075a] 21 32 22
                    ld        (_tty_buffer_head),hl         ;[075d] 22 88 2a
                    ld        hl,$2234                      ;[0760] 21 34 22
                    ld        (_tty_buffer_count),hl        ;[0763] 22 8a 2a
                    ld        hl,$2333                      ;[0766] 21 33 23
                    ld        (_tty_buffer),hl              ;[0769] 22 8c 2a
                    ld        hl,$2234                      ;[076c] 21 34 22
                    ld        (hl),$00                      ;[076f] 36 00
                    ld        hl,(_tty_buffer_head)         ;[0771] 2a 88 2a
                    ld        a,(_tty_buffer)               ;[0774] 3a 8c 2a
                    ld        (hl),a                        ;[0777] 77
                    inc       hl                            ;[0778] 23
                    ld        a,($2a8d)                     ;[0779] 3a 8d 2a
                    ld        (hl),a                        ;[077c] 77
                    ld        hl,(_tty_buffer_tail)         ;[077d] 2a 86 2a
                    ld        a,(_tty_buffer)               ;[0780] 3a 8c 2a
                    ld        (hl),a                        ;[0783] 77
                    inc       hl                            ;[0784] 23
                    ld        a,($2a8d)                     ;[0785] 3a 8d 2a
                    ld        (hl),a                        ;[0788] 77
                    ld        hl,$0000                      ;[0789] 21 00 00
                    ret                                     ;[078c] c9

_z80_rst_38h:
                    push      af                            ;[078d] f5
                    push      bc                            ;[078e] c5
                    push      de                            ;[078f] d5
                    push      hl                            ;[0790] e5
                    ld        hl,(_tty_buffer_count)        ;[0791] 2a 8a 2a
                    ld        a,(hl)                        ;[0794] 7e
                    push      iy                            ;[0795] fd e5
                    sub       $ff                           ;[0797] d6 ff
                    jr        nc,l_z80_rst_38h_00103        ;[0799] 30 27
                    ld        hl,(_tty_buffer_head)         ;[079b] 2a 88 2a
                    ld        c,(hl)                        ;[079e] 4e
                    ld        hl,(_tty_buffer)              ;[079f] 2a 8c 2a
                    ld        b,$00                         ;[07a2] 06 00
                    add       hl,bc                         ;[07a4] 09
                    ld        a,h                           ;[07a5] 7c
                    ld        c,l                           ;[07a6] 4d
                    ld        b,a                           ;[07a7] 47
                    in        a,($81)                       ;[07a8] db 81
                    ld        (bc),a                        ;[07aa] 02
                    ld        hl,(_tty_buffer_head)         ;[07ab] 2a 88 2a
                    ld        c,(hl)                        ;[07ae] 4e
                    ld        b,$00                         ;[07af] 06 00
                    inc       bc                            ;[07b1] 03
                    push      hl                            ;[07b2] e5
                    ld        de,$00ff                      ;[07b3] 11 ff 00
                    push      de                            ;[07b6] d5
                    push      bc                            ;[07b7] c5
                    call      __modsint_callee              ;[07b8] cd 3a 01
                    ex        de,hl                         ;[07bb] eb
                    pop       hl                            ;[07bc] e1
                    ld        (hl),e                        ;[07bd] 73
                    ld        hl,(_tty_buffer_count)        ;[07be] 2a 8a 2a
                    inc       (hl)                          ;[07c1] 34
l_z80_rst_38h_00103:
                    pop       iy                            ;[07c2] fd e1
                    pop       hl                            ;[07c4] e1
                    pop       de                            ;[07c5] d1
                    pop       bc                            ;[07c6] c1
                    pop       af                            ;[07c7] f1
                    ei                                      ;[07c8] fb
                    reti                                    ;[07c9] ed 4d

_z80_rst_08h:
                    out       ($81),a                       ;[07cb] d3 81
                    ei                                      ;[07cd] fb
                    reti                                    ;[07ce] ed 4d

_z80_rst_10h:
                    ei                                      ;[07d0] fb
                    push      af                            ;[07d1] f5
                    push      bc                            ;[07d2] c5
                    push      de                            ;[07d3] d5
                    push      hl                            ;[07d4] e5
                    push      iy                            ;[07d5] fd e5
                    push      ix                            ;[07d7] dd e5
                    ld        ix,$0000                      ;[07d9] dd 21 00 00
                    add       ix,sp                         ;[07dd] dd 39
                    push      af                            ;[07df] f5
l_z80_rst_10h_00101:
                    ld        hl,(_tty_buffer_count)        ;[07e0] 2a 8a 2a
                    ld        a,(hl)                        ;[07e3] 7e
                    or        a                             ;[07e4] b7
                    jr        z,l_z80_rst_10h_00101         ;[07e5] 28 f9
                    ld        a,(_tty_buffer_tail)          ;[07e7] 3a 86 2a
                    ld        c,a                           ;[07ea] 4f
                    ld        hl,$2a87                      ;[07eb] 21 87 2a
                    ld        b,(hl)                        ;[07ee] 46
                    ld        a,(bc)                        ;[07ef] 0a
                    ld        (ix-$01),a                    ;[07f0] dd 77 ff
                    ld        hl,$2a8c                      ;[07f3] 21 8c 2a
                    ld        a,(hl)                        ;[07f6] 7e
                    add       (ix-$01)                      ;[07f7] dd 86 ff
                    ld        e,a                           ;[07fa] 5f
                    inc       hl                            ;[07fb] 23
                    ld        a,(hl)                        ;[07fc] 7e
                    adc       $00                           ;[07fd] ce 00
                    ld        d,a                           ;[07ff] 57
                    ld        a,(de)                        ;[0800] 1a
                    ld        (ix-$02),a                    ;[0801] dd 77 fe
                    ld        e,(ix-$01)                    ;[0804] dd 5e ff
                    ld        d,$00                         ;[0807] 16 00
                    inc       de                            ;[0809] 13
                    push      bc                            ;[080a] c5
                    ld        hl,$00ff                      ;[080b] 21 ff 00
                    push      hl                            ;[080e] e5
                    push      de                            ;[080f] d5
                    call      __modsint_callee              ;[0810] cd 3a 01
                    pop       bc                            ;[0813] c1
                    ld        a,l                           ;[0814] 7d
                    ld        (bc),a                        ;[0815] 02
                    ld        hl,(_tty_buffer_count)        ;[0816] 2a 8a 2a
                    ld        a,(hl)                        ;[0819] 7e
                    dec       a                             ;[081a] 3d
                    ld        (hl),a                        ;[081b] 77
                    ld        a,(ix-$02)                    ;[081c] dd 7e fe
                    out       ($81),a                       ;[081f] d3 81
                    ld        a,(ix-$02)                    ;[0821] dd 7e fe
                    ld        sp,ix                         ;[0824] dd f9
                    pop       ix                            ;[0826] dd e1
                    pop       iy                            ;[0828] fd e1
                    pop       hl                            ;[082a] e1
                    pop       de                            ;[082b] d1
                    pop       bc                            ;[082c] c1
                    inc       sp                            ;[082d] 33
                    inc       sp                            ;[082e] 33
                    ei                                      ;[082f] fb
                    reti                                    ;[0830] ed 4d

                    ld        sp,ix                         ;[0832] dd f9
                    pop       ix                            ;[0834] dd e1
                    pop       iy                            ;[0836] fd e1
                    pop       hl                            ;[0838] e1
                    pop       de                            ;[0839] d1
                    pop       bc                            ;[083a] c1
                    pop       af                            ;[083b] f1
                    reti                                    ;[083c] ed 4d

_tty_getchar:
                    push      ix                            ;[083e] dd e5
                    ld        ix,$0000                      ;[0840] dd 21 00 00
                    add       ix,sp                         ;[0844] dd 39
                    dec       sp                            ;[0846] 3b
l_tty_getchar_00101:
                    ld        hl,(_tty_buffer_count)        ;[0847] 2a 8a 2a
                    ld        a,(hl)                        ;[084a] 7e
                    or        a                             ;[084b] b7
                    jr        z,l_tty_getchar_00101         ;[084c] 28 f9
                    ld        a,(_tty_buffer_tail)          ;[084e] 3a 86 2a
                    ld        c,a                           ;[0851] 4f
                    ld        hl,$2a87                      ;[0852] 21 87 2a
                    ld        b,(hl)                        ;[0855] 46
                    ld        a,(bc)                        ;[0856] 0a
                    ld        (ix-$01),a                    ;[0857] dd 77 ff
                    ld        hl,$2a8c                      ;[085a] 21 8c 2a
                    ld        a,(hl)                        ;[085d] 7e
                    add       (ix-$01)                      ;[085e] dd 86 ff
                    ld        e,a                           ;[0861] 5f
                    inc       hl                            ;[0862] 23
                    ld        a,(hl)                        ;[0863] 7e
                    adc       $00                           ;[0864] ce 00
                    ld        d,a                           ;[0866] 57
                    ld        a,(de)                        ;[0867] 1a
                    ld        e,a                           ;[0868] 5f
                    ld        l,(ix-$01)                    ;[0869] dd 6e ff
                    ld        h,$00                         ;[086c] 26 00
                    inc       hl                            ;[086e] 23
                    push      bc                            ;[086f] c5
                    push      de                            ;[0870] d5
                    push      hl                            ;[0871] e5
                    ld        hl,$00ff                      ;[0872] 21 ff 00
                    ex        (sp),hl                       ;[0875] e3
                    push      hl                            ;[0876] e5
                    call      __modsint_callee              ;[0877] cd 3a 01
                    pop       de                            ;[087a] d1
                    pop       bc                            ;[087b] c1
                    ld        a,l                           ;[087c] 7d
                    ld        (bc),a                        ;[087d] 02
                    ld        hl,(_tty_buffer_count)        ;[087e] 2a 8a 2a
                    ld        a,(hl)                        ;[0881] 7e
                    dec       a                             ;[0882] 3d
                    ld        (hl),a                        ;[0883] 77
                    ld        d,$00                         ;[0884] 16 00
                    inc       sp                            ;[0886] 33
                    ex        de,hl                         ;[0887] eb
                    pop       ix                            ;[0888] dd e1
                    ret                                     ;[088a] c9

_kputchar:
                    ld        a,l                           ;[088b] 7d
                    out       ($81),a                       ;[088c] d3 81
                    ld        hl,$0000                      ;[088e] 21 00 00
                    ret                                     ;[0891] c9

_mfs_init:
                    ld        a,$01                         ;[0892] 3e 01
                    push      af                            ;[0894] f5
                    inc       sp                            ;[0895] 33
                    ld        hl,$0000                      ;[0896] 21 00 00
                    push      hl                            ;[0899] e5
                    ld        h,$f2                         ;[089a] 26 f2
                    push      hl                            ;[089c] e5
                    call      _disk_read                    ;[089d] cd 6f 13
                    pop       af                            ;[08a0] f1
                    pop       af                            ;[08a1] f1
                    inc       sp                            ;[08a2] 33
                    ld        a,h                           ;[08a3] 7c
                    or        l                             ;[08a4] b5
                    jr        nz,l_mfs_init_00108           ;[08a5] 20 3a
                    ld        hl,(_checksum)                ;[08a7] 2a 50 17
                    ld        a,(hl)                        ;[08aa] 7e
                    inc       hl                            ;[08ab] 23
                    ld        b,(hl)                        ;[08ac] 46
                    sub       $ef                           ;[08ad] d6 ef
                    jr        nz,l_mfs_init_00140           ;[08af] 20 05
                    ld        a,b                           ;[08b1] 78
                    sub       $be                           ;[08b2] d6 be
                    jr        z,l_mfs_init_00102            ;[08b4] 28 06
l_mfs_init_00140:
                    ld        hl,$1576                      ;[08b6] 21 76 15
                    call      _kputs                        ;[08b9] cd 5c 06
l_mfs_init_00102:
                    ld        hl,(_formatted)               ;[08bc] 2a 52 17
                    ld        a,(hl)                        ;[08bf] 7e
                    or        a                             ;[08c0] b7
                    jr        nz,l_mfs_init_00106           ;[08c1] 20 16
                    ld        hl,$15b0                      ;[08c3] 21 b0 15
                    call      _kputs                        ;[08c6] cd 5c 06
                    call      _kgetchar                     ;[08c9] cd 53 06
                    ld        a,l                           ;[08cc] 7d
                    sub       $79                           ;[08cd] d6 79
                    jr        z,l_mfs_init_00104            ;[08cf] 28 05
                    ld        hl,$ffff                      ;[08d1] 21 ff ff
                    jr        l_mfs_init_00110              ;[08d4] 18 17
l_mfs_init_00104:
                    call      _mfs_format                   ;[08d6] cd ee 08
l_mfs_init_00106:
                    ld        hl,$15dc                      ;[08d9] 21 dc 15
                    call      _kputs                        ;[08dc] cd 5c 06
                    jr        l_mfs_init_00109              ;[08df] 18 09
l_mfs_init_00108:
                    ld        hl,$15ed                      ;[08e1] 21 ed 15
                    call      _kputs                        ;[08e4] cd 5c 06
                    call      _kernel_panic                 ;[08e7] cd 12 02
l_mfs_init_00109:
                    ld        hl,$0000                      ;[08ea] 21 00 00
l_mfs_init_00110:
                    ret                                     ;[08ed] c9

_mfs_format:
                    ld        hl,(_tempbuf)                 ;[08ee] 2a 5a 17
                    ld        (hl),$00                      ;[08f1] 36 00
                    ld        e,l                           ;[08f3] 5d
                    ld        d,h                           ;[08f4] 54
                    inc       de                            ;[08f5] 13
                    ld        bc,$01ff                      ;[08f6] 01 ff 01
                    ldir                                    ;[08f9] ed b0
                    ld        hl,(_tempbuf)                 ;[08fb] 2a 5a 17
                    ld        (hl),$ef                      ;[08fe] 36 ef
                    inc       hl                            ;[0900] 23
                    ld        (hl),$be                      ;[0901] 36 be
                    ld        hl,(_tempbuf)                 ;[0903] 2a 5a 17
                    inc       hl                            ;[0906] 23
                    inc       hl                            ;[0907] 23
                    ld        e,h                           ;[0908] 5c
                    ld        (hl),$01                      ;[0909] 36 01
                    ld        a,(_tempbuf)                  ;[090b] 3a 5a 17
                    ld        c,a                           ;[090e] 4f
                    ld        hl,$175b                      ;[090f] 21 5b 17
                    ld        b,(hl)                        ;[0912] 46
                    inc       bc                            ;[0913] 03
                    inc       bc                            ;[0914] 03
                    inc       bc                            ;[0915] 03
                    xor       a                             ;[0916] af
                    ld        (bc),a                        ;[0917] 02
                    ld        hl,(_checksum)                ;[0918] 2a 50 17
                    ld        (hl),$ef                      ;[091b] 36 ef
                    inc       hl                            ;[091d] 23
                    ld        (hl),$be                      ;[091e] 36 be
                    ld        hl,(_formatted)               ;[0920] 2a 52 17
                    ld        a,$01                         ;[0923] 3e 01
                    ld        (hl),a                        ;[0925] 77
                    push      af                            ;[0926] f5
                    inc       sp                            ;[0927] 33
                    ld        hl,$0000                      ;[0928] 21 00 00
                    push      hl                            ;[092b] e5
                    ld        hl,(_tempbuf)                 ;[092c] 2a 5a 17
                    push      hl                            ;[092f] e5
                    call      _disk_write                   ;[0930] cd 92 13
                    pop       af                            ;[0933] f1
                    pop       af                            ;[0934] f1
                    inc       sp                            ;[0935] 33
                    ld        hl,(_tempbuf)                 ;[0936] 2a 5a 17
                    ld        (hl),$00                      ;[0939] 36 00
                    ld        e,l                           ;[093b] 5d
                    ld        d,h                           ;[093c] 54
                    inc       de                            ;[093d] 13
                    ld        bc,$01ff                      ;[093e] 01 ff 01
                    ldir                                    ;[0941] ed b0
                    ld        bc,$0001                      ;[0943] 01 01 00
l_mfs_format_00103:
                    ld        a,c                           ;[0946] 79
                    sub       $ff                           ;[0947] d6 ff
                    jr        nc,l_mfs_format_00101         ;[0949] 30 14
                    push      bc                            ;[094b] c5
                    ld        a,$01                         ;[094c] 3e 01
                    push      af                            ;[094e] f5
                    inc       sp                            ;[094f] 33
                    ld        hl,(_tempbuf)                 ;[0950] 2a 5a 17
                    push      bc                            ;[0953] c5
                    push      hl                            ;[0954] e5
                    call      _disk_write                   ;[0955] cd 92 13
                    pop       af                            ;[0958] f1
                    pop       af                            ;[0959] f1
                    inc       sp                            ;[095a] 33
                    pop       bc                            ;[095b] c1
                    inc       bc                            ;[095c] 03
                    jr        l_mfs_format_00103            ;[095d] 18 e7
l_mfs_format_00101:
                    ld        hl,$0000                      ;[095f] 21 00 00
                    ret                                     ;[0962] c9

_mfs_exit:
                    call      _write_changes                ;[0963] cd c5 09
                    ld        hl,$0000                      ;[0966] 21 00 00
                    ret                                     ;[0969] c9

_print_file_info:
                    push      hl                            ;[096a] e5
                    ld        hl,$1606                      ;[096b] 21 06 16
                    call      _kputs                        ;[096e] cd 5c 06
                    pop       hl                            ;[0971] e1
                    ld        e,l                           ;[0972] 5d
                    ld        d,h                           ;[0973] 54
                    inc       hl                            ;[0974] 23
                    inc       hl                            ;[0975] 23
                    push      de                            ;[0976] d5
                    call      _kputs                        ;[0977] cd 5c 06
                    ld        l,$0a                         ;[097a] 2e 0a
                    call      _kputchar                     ;[097c] cd 8b 08
                    ld        hl,$160d                      ;[097f] 21 0d 16
                    call      _kputs                        ;[0982] cd 5c 06
                    pop       de                            ;[0985] d1
                    ld        hl,$000b                      ;[0986] 21 0b 00
                    add       hl,de                         ;[0989] 19
                    ld        a,(hl)                        ;[098a] 7e
                    dec       hl                            ;[098b] 2b
                    ld        l,(hl)                        ;[098c] 6e
                    push      de                            ;[098d] d5
                    ld        h,a                           ;[098e] 67
                    call      _kputh                        ;[098f] cd fd 06
                    ld        l,$0a                         ;[0992] 2e 0a
                    call      _kputchar                     ;[0994] cd 8b 08
                    ld        hl,$1614                      ;[0997] 21 14 16
                    call      _kputs                        ;[099a] cd 5c 06
                    pop       de                            ;[099d] d1
                    ld        hl,$000c                      ;[099e] 21 0c 00
                    add       hl,de                         ;[09a1] 19
                    ld        l,(hl)                        ;[09a2] 6e
                    ld        h,$00                         ;[09a3] 26 00
                    push      de                            ;[09a5] d5
                    call      _kputh                        ;[09a6] cd fd 06
                    ld        l,$0a                         ;[09a9] 2e 0a
                    call      _kputchar                     ;[09ab] cd 8b 08
                    ld        hl,$1621                      ;[09ae] 21 21 16
                    call      _kputs                        ;[09b1] cd 5c 06
                    pop       de                            ;[09b4] d1
                    ld        hl,$000d                      ;[09b5] 21 0d 00
                    add       hl,de                         ;[09b8] 19
                    ld        a,(hl)                        ;[09b9] 7e
                    inc       hl                            ;[09ba] 23
                    ld        h,(hl)                        ;[09bb] 66
                    ld        l,a                           ;[09bc] 6f
                    call      _kputh                        ;[09bd] cd fd 06
                    ld        l,$0a                         ;[09c0] 2e 0a
                    jp        _kputchar                     ;[09c2] c3 8b 08
_write_changes:
                    ld        a,$01                         ;[09c5] 3e 01
                    push      af                            ;[09c7] f5
                    inc       sp                            ;[09c8] 33
                    ld        hl,$0000                      ;[09c9] 21 00 00
                    push      hl                            ;[09cc] e5
                    ld        hl,(_fs_rootfs)               ;[09cd] 2a 58 17
                    push      hl                            ;[09d0] e5
                    call      _disk_write                   ;[09d1] cd 92 13
                    pop       af                            ;[09d4] f1
                    pop       af                            ;[09d5] f1
                    inc       sp                            ;[09d6] 33
                    ld        bc,$0000                      ;[09d7] 01 00 00
l_write_changes_00106:
                    ld        hl,(_filecount)               ;[09da] 2a 54 17
                    ld        e,(hl)                        ;[09dd] 5e
                    ld        d,$00                         ;[09de] 16 00
                    ld        a,c                           ;[09e0] 79
                    sub       e                             ;[09e1] 93
                    ld        a,b                           ;[09e2] 78
                    sbc       d                             ;[09e3] 9a
                    jp        po,l_write_changes_00139      ;[09e4] e2 e9 09
                    xor       $80                           ;[09e7] ee 80
l_write_changes_00139:
                    jp        p,l_write_changes_00108       ;[09e9] f2 09 0a
                    ld        l,c                           ;[09ec] 69
                    ld        h,b                           ;[09ed] 60
                    add       hl,hl                         ;[09ee] 29
                    add       hl,bc                         ;[09ef] 09
                    add       hl,hl                         ;[09f0] 29
                    add       hl,bc                         ;[09f1] 09
                    add       hl,hl                         ;[09f2] 29
                    add       hl,bc                         ;[09f3] 09
                    ex        de,hl                         ;[09f4] eb
                    ld        hl,(_files)                   ;[09f5] 2a 56 17
                    add       hl,de                         ;[09f8] 19
                    ld        a,(hl)                        ;[09f9] 7e
                    bit       1,a                           ;[09fa] cb 4f
                    ex        de,hl                         ;[09fc] eb
                    jr        z,l_write_changes_00107       ;[09fd] 28 07
                    cp        $02                           ;[09ff] fe 02
                    jr        z,l_write_changes_00107       ;[0a01] 28 03
                    and       $fd                           ;[0a03] e6 fd
                    ld        (de),a                        ;[0a05] 12
l_write_changes_00107:
                    inc       bc                            ;[0a06] 03
                    jr        l_write_changes_00106         ;[0a07] 18 d1
l_write_changes_00108:
                    ret                                     ;[0a09] c9

_find_free_block:
                    push      ix                            ;[0a0a] dd e5
                    ld        ix,$0000                      ;[0a0c] dd 21 00 00
                    add       ix,sp                         ;[0a10] dd 39
                    ld        hl,$fdfb                      ;[0a12] 21 fb fd
                    add       hl,sp                         ;[0a15] 39
                    ld        sp,hl                         ;[0a16] f9
                    ld        hl,$0000                      ;[0a17] 21 00 00
                    add       hl,sp                         ;[0a1a] 39
                    ld        (hl),$00                      ;[0a1b] 36 00
                    ld        e,l                           ;[0a1d] 5d
                    ld        d,h                           ;[0a1e] 54
                    inc       de                            ;[0a1f] 13
                    ld        bc,$01ff                      ;[0a20] 01 ff 01
                    ldir                                    ;[0a23] ed b0
                    ld        (ix-$05),$01                  ;[0a25] dd 36 fb 01
                    xor       a                             ;[0a29] af
                    ld        (ix-$04),a                    ;[0a2a] dd 77 fc
                    ld        bc,$0001                      ;[0a2d] 01 01 00
l_find_free_block_00119:
                    ld        a,c                           ;[0a30] 79
                    sub       $ff                           ;[0a31] d6 ff
                    ld        a,b                           ;[0a33] 78
                    sbc       $00                           ;[0a34] de 00
                    jp        nc,l_find_free_block_00114    ;[0a36] d2 e4 0a
                    push      bc                            ;[0a39] c5
                    ld        a,$01                         ;[0a3a] 3e 01
                    push      af                            ;[0a3c] f5
                    inc       sp                            ;[0a3d] 33
                    push      bc                            ;[0a3e] c5
                    ld        hl,$0005                      ;[0a3f] 21 05 00
                    add       hl,sp                         ;[0a42] 39
                    push      hl                            ;[0a43] e5
                    call      _disk_read                    ;[0a44] cd 6f 13
                    pop       af                            ;[0a47] f1
                    pop       af                            ;[0a48] f1
                    inc       sp                            ;[0a49] 33
                    pop       bc                            ;[0a4a] c1
                    ld        hl,$0000                      ;[0a4b] 21 00 00
                    add       hl,sp                         ;[0a4e] 39
                    ld        a,(hl)                        ;[0a4f] 7e
                    or        a                             ;[0a50] b7
                    jp        nz,l_find_free_block_00120    ;[0a51] c2 da 0a
                    ld        (ix-$03),$00                  ;[0a54] dd 36 fd 00
                    xor       a                             ;[0a58] af
                    ld        (ix-$02),a                    ;[0a59] dd 77 fe
                    ld        (ix-$01),a                    ;[0a5c] dd 77 ff
l_find_free_block_00116:
                    ld        hl,(_filecount)               ;[0a5f] 2a 54 17
                    ld        e,(hl)                        ;[0a62] 5e
                    ld        d,$00                         ;[0a63] 16 00
                    ld        a,(ix-$02)                    ;[0a65] dd 7e fe
                    sub       e                             ;[0a68] 93
                    ld        a,(ix-$01)                    ;[0a69] dd 7e ff
                    sbc       d                             ;[0a6c] 9a
                    jr        nc,l_find_free_block_00109    ;[0a6d] 30 5d
                    ld        l,(ix-$02)                    ;[0a6f] dd 6e fe
                    ld        h,(ix-$01)                    ;[0a72] dd 66 ff
                    ld        e,l                           ;[0a75] 5d
                    ld        d,h                           ;[0a76] 54
                    add       hl,hl                         ;[0a77] 29
                    add       hl,de                         ;[0a78] 19
                    add       hl,hl                         ;[0a79] 29
                    add       hl,de                         ;[0a7a] 19
                    add       hl,hl                         ;[0a7b] 29
                    add       hl,de                         ;[0a7c] 19
                    ex        de,hl                         ;[0a7d] eb
                    ld        hl,(_files)                   ;[0a7e] 2a 56 17
                    add       hl,de                         ;[0a81] 19
                    ld        de,$000d                      ;[0a82] 11 0d 00
                    add       hl,de                         ;[0a85] 19
                    ld        e,(hl)                        ;[0a86] 5e
                    inc       hl                            ;[0a87] 23
                    ld        d,(hl)                        ;[0a88] 56
l_find_free_block_00104:
                    ld        a,d                           ;[0a89] 7a
                    or        e                             ;[0a8a] b3
                    jr        z,l_find_free_block_00106     ;[0a8b] 28 2f
                    ld        a,e                           ;[0a8d] 7b
                    sub       $ff                           ;[0a8e] d6 ff
                    ld        a,d                           ;[0a90] 7a
                    sbc       $00                           ;[0a91] de 00
                    jr        nc,l_find_free_block_00106    ;[0a93] 30 27
                    ld        l,e                           ;[0a95] 6b
                    ld        h,d                           ;[0a96] 62
                    xor       a                             ;[0a97] af
                    sbc       hl,bc                         ;[0a98] ed 42
                    jr        nz,l_find_free_block_00102    ;[0a9a] 20 06
                    ld        (ix-$03),$01                  ;[0a9c] dd 36 fd 01
                    jr        l_find_free_block_00106       ;[0aa0] 18 1a
l_find_free_block_00102:
                    push      bc                            ;[0aa2] c5
                    ld        a,$01                         ;[0aa3] 3e 01
                    push      af                            ;[0aa5] f5
                    inc       sp                            ;[0aa6] 33
                    ld        hl,(_tempbuf)                 ;[0aa7] 2a 5a 17
                    push      de                            ;[0aaa] d5
                    push      hl                            ;[0aab] e5
                    call      _disk_read                    ;[0aac] cd 6f 13
                    pop       af                            ;[0aaf] f1
                    pop       af                            ;[0ab0] f1
                    inc       sp                            ;[0ab1] 33
                    pop       bc                            ;[0ab2] c1
                    ld        hl,(_tempbuf)                 ;[0ab3] 2a 5a 17
                    inc       hl                            ;[0ab6] 23
                    ld        e,(hl)                        ;[0ab7] 5e
                    inc       hl                            ;[0ab8] 23
                    ld        d,(hl)                        ;[0ab9] 56
                    jr        l_find_free_block_00104       ;[0aba] 18 cd
l_find_free_block_00106:
                    ld        a,(ix-$03)                    ;[0abc] dd 7e fd
                    or        a                             ;[0abf] b7
                    jr        nz,l_find_free_block_00109    ;[0ac0] 20 0a
                    inc       (ix-$02)                      ;[0ac2] dd 34 fe
                    jr        nz,l_find_free_block_00116    ;[0ac5] 20 98
                    inc       (ix-$01)                      ;[0ac7] dd 34 ff
                    jr        l_find_free_block_00116       ;[0aca] 18 93
l_find_free_block_00109:
                    ld        a,(ix-$03)                    ;[0acc] dd 7e fd
                    or        a                             ;[0acf] b7
                    jr        nz,l_find_free_block_00120    ;[0ad0] 20 08
                    ld        l,(ix-$05)                    ;[0ad2] dd 6e fb
                    ld        h,(ix-$04)                    ;[0ad5] dd 66 fc
                    jr        l_find_free_block_00121       ;[0ad8] 18 0d
l_find_free_block_00120:
                    inc       bc                            ;[0ada] 03
                    ld        (ix-$05),c                    ;[0adb] dd 71 fb
                    ld        (ix-$04),b                    ;[0ade] dd 70 fc
                    jp        l_find_free_block_00119       ;[0ae1] c3 30 0a
l_find_free_block_00114:
                    ld        hl,$0000                      ;[0ae4] 21 00 00
l_find_free_block_00121:
                    ld        sp,ix                         ;[0ae7] dd f9
                    pop       ix                            ;[0ae9] dd e1
                    ret                                     ;[0aeb] c9

_find_file:
                    push      ix                            ;[0aec] dd e5
                    ld        ix,$0000                      ;[0aee] dd 21 00 00
                    add       ix,sp                         ;[0af2] dd 39
                    push      af                            ;[0af4] f5
                    dec       sp                            ;[0af5] 3b
                    ex        (sp),hl                       ;[0af6] e3
                    ld        (ix-$01),$00                  ;[0af7] dd 36 ff 00
l_find_file_00105:
                    ld        hl,(_filecount)               ;[0afb] 2a 54 17
                    ld        a,(ix-$01)                    ;[0afe] dd 7e ff
                    sub       (hl)                          ;[0b01] 96
                    jr        nc,l_find_file_00103          ;[0b02] 30 36
                    ld        l,(ix-$01)                    ;[0b04] dd 6e ff
                    ld        h,$00                         ;[0b07] 26 00
                    ld        c,l                           ;[0b09] 4d
                    ld        b,h                           ;[0b0a] 44
                    add       hl,hl                         ;[0b0b] 29
                    add       hl,bc                         ;[0b0c] 09
                    add       hl,hl                         ;[0b0d] 29
                    add       hl,bc                         ;[0b0e] 09
                    add       hl,hl                         ;[0b0f] 29
                    add       hl,bc                         ;[0b10] 09
                    ex        de,hl                         ;[0b11] eb
                    ld        hl,(_files)                   ;[0b12] 2a 56 17
                    add       hl,de                         ;[0b15] 19
                    inc       hl                            ;[0b16] 23
                    inc       hl                            ;[0b17] 23
                    ld        c,l                           ;[0b18] 4d
                    ld        b,h                           ;[0b19] 44
                    push      de                            ;[0b1a] d5
                    ld        hl,$0008                      ;[0b1b] 21 08 00
                    push      hl                            ;[0b1e] e5
                    push      bc                            ;[0b1f] c5
                    ld        l,(ix-$03)                    ;[0b20] dd 6e fd
                    ld        h,(ix-$02)                    ;[0b23] dd 66 fe
                    push      hl                            ;[0b26] e5
                    call      _strncmp_callee               ;[0b27] cd aa 01
                    pop       de                            ;[0b2a] d1
                    ld        a,h                           ;[0b2b] 7c
                    or        l                             ;[0b2c] b5
                    jr        nz,l_find_file_00106          ;[0b2d] 20 06
                    ld        hl,(_files)                   ;[0b2f] 2a 56 17
                    add       hl,de                         ;[0b32] 19
                    jr        l_find_file_00107             ;[0b33] 18 08
l_find_file_00106:
                    inc       (ix-$01)                      ;[0b35] dd 34 ff
                    jr        l_find_file_00105             ;[0b38] 18 c1
l_find_file_00103:
                    ld        hl,$0000                      ;[0b3a] 21 00 00
l_find_file_00107:
                    ld        sp,ix                         ;[0b3d] dd f9
                    pop       ix                            ;[0b3f] dd e1
                    ret                                     ;[0b41] c9

_get_file_block:
                    push      ix                            ;[0b42] dd e5
                    ld        ix,$0000                      ;[0b44] dd 21 00 00
                    add       ix,sp                         ;[0b48] dd 39
                    push      af                            ;[0b4a] f5
                    dec       sp                            ;[0b4b] 3b
                    ex        (sp),hl                       ;[0b4c] e3
                    ld        (ix-$01),$00                  ;[0b4d] dd 36 ff 00
l_get_file_block_00105:
                    ld        hl,(_filecount)               ;[0b51] 2a 54 17
                    ld        a,(ix-$01)                    ;[0b54] dd 7e ff
                    sub       (hl)                          ;[0b57] 96
                    jr        nc,l_get_file_block_00103     ;[0b58] 30 3e
                    ld        l,(ix-$01)                    ;[0b5a] dd 6e ff
                    ld        h,$00                         ;[0b5d] 26 00
                    ld        c,l                           ;[0b5f] 4d
                    ld        b,h                           ;[0b60] 44
                    add       hl,hl                         ;[0b61] 29
                    add       hl,bc                         ;[0b62] 09
                    add       hl,hl                         ;[0b63] 29
                    add       hl,bc                         ;[0b64] 09
                    add       hl,hl                         ;[0b65] 29
                    add       hl,bc                         ;[0b66] 09
                    ex        de,hl                         ;[0b67] eb
                    ld        hl,(_files)                   ;[0b68] 2a 56 17
                    add       hl,de                         ;[0b6b] 19
                    inc       hl                            ;[0b6c] 23
                    inc       hl                            ;[0b6d] 23
                    ld        c,l                           ;[0b6e] 4d
                    ld        b,h                           ;[0b6f] 44
                    push      de                            ;[0b70] d5
                    ld        hl,$0008                      ;[0b71] 21 08 00
                    push      hl                            ;[0b74] e5
                    push      bc                            ;[0b75] c5
                    ld        l,(ix-$03)                    ;[0b76] dd 6e fd
                    ld        h,(ix-$02)                    ;[0b79] dd 66 fe
                    push      hl                            ;[0b7c] e5
                    call      _strncmp_callee               ;[0b7d] cd aa 01
                    pop       de                            ;[0b80] d1
                    ld        a,h                           ;[0b81] 7c
                    or        l                             ;[0b82] b5
                    jr        nz,l_get_file_block_00106     ;[0b83] 20 0e
                    ld        hl,(_files)                   ;[0b85] 2a 56 17
                    add       hl,de                         ;[0b88] 19
                    ld        bc,$000d                      ;[0b89] 01 0d 00
                    add       hl,bc                         ;[0b8c] 09
                    ld        a,(hl)                        ;[0b8d] 7e
                    inc       hl                            ;[0b8e] 23
                    ld        h,(hl)                        ;[0b8f] 66
                    ld        l,a                           ;[0b90] 6f
                    jr        l_get_file_block_00107        ;[0b91] 18 08
l_get_file_block_00106:
                    inc       (ix-$01)                      ;[0b93] dd 34 ff
                    jr        l_get_file_block_00105        ;[0b96] 18 b9
l_get_file_block_00103:
                    ld        hl,$0000                      ;[0b98] 21 00 00
l_get_file_block_00107:
                    ld        sp,ix                         ;[0b9b] dd f9
                    pop       ix                            ;[0b9d] dd e1
                    ret                                     ;[0b9f] c9

_get_file_index:
                    push      ix                            ;[0ba0] dd e5
                    ld        ix,$0000                      ;[0ba2] dd 21 00 00
                    add       ix,sp                         ;[0ba6] dd 39
                    push      af                            ;[0ba8] f5
                    ex        (sp),hl                       ;[0ba9] e3
                    ld        bc,$0000                      ;[0baa] 01 00 00
l_get_file_index_00105:
                    ld        hl,(_filecount)               ;[0bad] 2a 54 17
                    ld        e,(hl)                        ;[0bb0] 5e
                    ld        a,b                           ;[0bb1] 78
                    sub       e                             ;[0bb2] 93
                    jr        nc,l_get_file_index_00103     ;[0bb3] 30 2f
                    ld        e,b                           ;[0bb5] 58
                    ld        d,$00                         ;[0bb6] 16 00
                    ld        l,e                           ;[0bb8] 6b
                    ld        h,d                           ;[0bb9] 62
                    add       hl,hl                         ;[0bba] 29
                    add       hl,de                         ;[0bbb] 19
                    add       hl,hl                         ;[0bbc] 29
                    add       hl,de                         ;[0bbd] 19
                    add       hl,hl                         ;[0bbe] 29
                    add       hl,de                         ;[0bbf] 19
                    ex        de,hl                         ;[0bc0] eb
                    ld        hl,(_files)                   ;[0bc1] 2a 56 17
                    add       hl,de                         ;[0bc4] 19
                    ex        de,hl                         ;[0bc5] eb
                    inc       de                            ;[0bc6] 13
                    inc       de                            ;[0bc7] 13
                    push      bc                            ;[0bc8] c5
                    ld        hl,$0008                      ;[0bc9] 21 08 00
                    push      hl                            ;[0bcc] e5
                    push      de                            ;[0bcd] d5
                    ld        l,(ix-$02)                    ;[0bce] dd 6e fe
                    ld        h,(ix-$01)                    ;[0bd1] dd 66 ff
                    push      hl                            ;[0bd4] e5
                    call      _strncmp_callee               ;[0bd5] cd aa 01
                    pop       bc                            ;[0bd8] c1
                    ld        a,h                           ;[0bd9] 7c
                    or        l                             ;[0bda] b5
                    jr        nz,l_get_file_index_00106     ;[0bdb] 20 03
                    ld        l,c                           ;[0bdd] 69
                    jr        l_get_file_index_00107        ;[0bde] 18 06
l_get_file_index_00106:
                    inc       b                             ;[0be0] 04
                    ld        c,b                           ;[0be1] 48
                    jr        l_get_file_index_00105        ;[0be2] 18 c9
l_get_file_index_00103:
                    ld        l,$ff                         ;[0be4] 2e ff
l_get_file_index_00107:
                    ld        sp,ix                         ;[0be6] dd f9
                    pop       ix                            ;[0be8] dd e1
                    ret                                     ;[0bea] c9

_load_to_memory:
                    push      ix                            ;[0beb] dd e5
                    ld        ix,$0000                      ;[0bed] dd 21 00 00
                    add       ix,sp                         ;[0bf1] dd 39
                    push      af                            ;[0bf3] f5
                    push      af                            ;[0bf4] f5
                    push      af                            ;[0bf5] f5
                    call      _get_file_index               ;[0bf6] cd a0 0b
                    ld        c,l                           ;[0bf9] 4d
                    ld        b,$00                         ;[0bfa] 06 00
                    ld        a,c                           ;[0bfc] 79
                    inc       a                             ;[0bfd] 3c
                    or        b                             ;[0bfe] b0
                    jr        nz,l_load_to_memory_00102     ;[0bff] 20 06
                    ld        hl,$ffff                      ;[0c01] 21 ff ff
                    jp        l_load_to_memory_00108        ;[0c04] c3 d2 0c
l_load_to_memory_00102:
                    ld        l,c                           ;[0c07] 69
                    ld        h,b                           ;[0c08] 60
                    add       hl,hl                         ;[0c09] 29
                    add       hl,bc                         ;[0c0a] 09
                    add       hl,hl                         ;[0c0b] 29
                    add       hl,bc                         ;[0c0c] 09
                    add       hl,hl                         ;[0c0d] 29
                    add       hl,bc                         ;[0c0e] 09
                    ld        c,l                           ;[0c0f] 4d
                    ld        b,h                           ;[0c10] 44
                    ld        hl,(_files)                   ;[0c11] 2a 56 17
                    add       hl,bc                         ;[0c14] 09
                    ex        de,hl                         ;[0c15] eb
                    ld        hl,$1757                      ;[0c16] 21 57 17
                    push      bc                            ;[0c19] c5
                    ex        de,hl                         ;[0c1a] eb
                    call      _print_file_info              ;[0c1b] cd 6a 09
                    pop       bc                            ;[0c1e] c1
                    ld        hl,(_files)                   ;[0c1f] 2a 56 17
                    add       hl,bc                         ;[0c22] 09
                    ld        c,l                           ;[0c23] 4d
                    ld        b,h                           ;[0c24] 44
                    ld        hl,$000a                      ;[0c25] 21 0a 00
                    add       hl,bc                         ;[0c28] 09
                    ld        a,(hl)                        ;[0c29] 7e
                    ld        (ix-$06),a                    ;[0c2a] dd 77 fa
                    inc       hl                            ;[0c2d] 23
                    ld        a,(hl)                        ;[0c2e] 7e
                    ld        (ix-$05),a                    ;[0c2f] dd 77 fb
                    ld        hl,$000d                      ;[0c32] 21 0d 00
                    add       hl,bc                         ;[0c35] 09
                    ld        a,(hl)                        ;[0c36] 7e
                    inc       hl                            ;[0c37] 23
                    ld        h,(hl)                        ;[0c38] 66
                    ld        l,a                           ;[0c39] 6f
                    ld        de,$0000                      ;[0c3a] 11 00 00
l_load_to_memory_00105:
                    ld        a,(ix-$05)                    ;[0c3d] dd 7e fb
                    or        (ix-$06)                      ;[0c40] dd b6 fa
                    jp        z,l_load_to_memory_00107      ;[0c43] ca cf 0c
                    ld        a,h                           ;[0c46] 7c
                    or        l                             ;[0c47] b5
                    jp        z,l_load_to_memory_00107      ;[0c48] ca cf 0c
                    ld        a,l                           ;[0c4b] 7d
                    sub       $ff                           ;[0c4c] d6 ff
                    ld        a,h                           ;[0c4e] 7c
                    sbc       $00                           ;[0c4f] de 00
                    jr        nc,l_load_to_memory_00107     ;[0c51] 30 7c
                    ld        a,$fc                         ;[0c53] 3e fc
                    cp        (ix-$06)                      ;[0c55] dd be fa
                    ld        a,$01                         ;[0c58] 3e 01
                    sbc       (ix-$05)                      ;[0c5a] dd 9e fb
                    jp        po,l_load_to_memory_00156     ;[0c5d] e2 62 0c
                    xor       $80                           ;[0c60] ee 80
l_load_to_memory_00156:
                    jp        p,l_load_to_memory_00110      ;[0c62] f2 6a 0c
                    ld        bc,$01fc                      ;[0c65] 01 fc 01
                    jr        l_load_to_memory_00111        ;[0c68] 18 02
l_load_to_memory_00110:
                    pop       bc                            ;[0c6a] c1
                    push      bc                            ;[0c6b] c5
l_load_to_memory_00111:
                    push      bc                            ;[0c6c] c5
                    push      de                            ;[0c6d] d5
                    ld        a,$01                         ;[0c6e] 3e 01
                    push      af                            ;[0c70] f5
                    inc       sp                            ;[0c71] 33
                    push      hl                            ;[0c72] e5
                    ld        hl,(_tempbuf)                 ;[0c73] 2a 5a 17
                    push      hl                            ;[0c76] e5
                    call      _disk_read                    ;[0c77] cd 6f 13
                    pop       af                            ;[0c7a] f1
                    pop       af                            ;[0c7b] f1
                    inc       sp                            ;[0c7c] 33
                    pop       de                            ;[0c7d] d1
                    pop       bc                            ;[0c7e] c1
                    ld        hl,$4020                      ;[0c7f] 21 20 40
                    add       hl,de                         ;[0c82] 19
                    ld        (ix-$04),l                    ;[0c83] dd 75 fc
                    ld        (ix-$03),h                    ;[0c86] dd 74 fd
                    ld        hl,$175a                      ;[0c89] 21 5a 17
                    ld        a,(hl)                        ;[0c8c] 7e
                    add       $04                           ;[0c8d] c6 04
                    ld        (ix-$02),a                    ;[0c8f] dd 77 fe
                    inc       hl                            ;[0c92] 23
                    ld        a,(hl)                        ;[0c93] 7e
                    adc       $00                           ;[0c94] ce 00
                    ld        (ix-$01),a                    ;[0c96] dd 77 ff
                    push      de                            ;[0c99] d5
                    push      bc                            ;[0c9a] c5
                    ld        e,(ix-$04)                    ;[0c9b] dd 5e fc
                    ld        d,(ix-$03)                    ;[0c9e] dd 56 fd
                    ld        l,(ix-$02)                    ;[0ca1] dd 6e fe
                    ld        h,(ix-$01)                    ;[0ca4] dd 66 ff
                    ld        a,b                           ;[0ca7] 78
                    or        c                             ;[0ca8] b1
                    jr        z,l_load_to_memory_00157      ;[0ca9] 28 02
                    ldir                                    ;[0cab] ed b0
l_load_to_memory_00157:
                    pop       bc                            ;[0cad] c1
                    pop       de                            ;[0cae] d1
                    ld        a,e                           ;[0caf] 7b
                    add       c                             ;[0cb0] 81
                    ld        e,a                           ;[0cb1] 5f
                    ld        a,d                           ;[0cb2] 7a
                    adc       b                             ;[0cb3] 88
                    ld        d,a                           ;[0cb4] 57
                    ld        l,(ix-$05)                    ;[0cb5] dd 6e fb
                    ld        a,(ix-$06)                    ;[0cb8] dd 7e fa
                    sub       c                             ;[0cbb] 91
                    ld        (ix-$06),a                    ;[0cbc] dd 77 fa
                    ld        a,l                           ;[0cbf] 7d
                    sbc       b                             ;[0cc0] 98
                    ld        (ix-$05),a                    ;[0cc1] dd 77 fb
                    ld        hl,(_tempbuf)                 ;[0cc4] 2a 5a 17
                    inc       hl                            ;[0cc7] 23
                    ld        a,(hl)                        ;[0cc8] 7e
                    inc       hl                            ;[0cc9] 23
                    ld        h,(hl)                        ;[0cca] 66
                    ld        l,a                           ;[0ccb] 6f
                    jp        l_load_to_memory_00105        ;[0ccc] c3 3d 0c
l_load_to_memory_00107:
                    ld        hl,$0000                      ;[0ccf] 21 00 00
l_load_to_memory_00108:
                    ld        sp,ix                         ;[0cd2] dd f9
                    pop       ix                            ;[0cd4] dd e1
                    ret                                     ;[0cd6] c9

_save_to_disk:
                    push      ix                            ;[0cd7] dd e5
                    ld        ix,$0000                      ;[0cd9] dd 21 00 00
                    add       ix,sp                         ;[0cdd] dd 39
                    ld        c,l                           ;[0cdf] 4d
                    ld        b,h                           ;[0ce0] 44
                    ld        hl,$fd65                      ;[0ce1] 21 65 fd
                    add       hl,sp                         ;[0ce4] 39
                    ld        sp,hl                         ;[0ce5] f9
                    ld        (ix-$05),c                    ;[0ce6] dd 71 fb
                    ld        l,c                           ;[0ce9] 69
                    ld        (ix-$04),b                    ;[0cea] dd 70 fc
                    ld        h,b                           ;[0ced] 60
                    call      _get_file_index               ;[0cee] cd a0 0b
                    ld        c,l                           ;[0cf1] 4d
                    ld        b,$00                         ;[0cf2] 06 00
                    ld        a,c                           ;[0cf4] 79
                    inc       a                             ;[0cf5] 3c
                    or        b                             ;[0cf6] b0
                    jr        nz,l_save_to_disk_00102       ;[0cf7] 20 06
                    ld        hl,$ffff                      ;[0cf9] 21 ff ff
                    jp        l_save_to_disk_00118          ;[0cfc] c3 08 0f
l_save_to_disk_00102:
                    ld        l,c                           ;[0cff] 69
                    ld        h,b                           ;[0d00] 60
                    add       hl,hl                         ;[0d01] 29
                    add       hl,bc                         ;[0d02] 09
                    add       hl,hl                         ;[0d03] 29
                    add       hl,bc                         ;[0d04] 09
                    add       hl,hl                         ;[0d05] 29
                    add       hl,bc                         ;[0d06] 09
                    ld        (ix-$0c),l                    ;[0d07] dd 75 f4
                    ld        (ix-$0b),h                    ;[0d0a] dd 74 f5
                    ld        bc,(_files)                   ;[0d0d] ed 4b 56 17
                    add       hl,bc                         ;[0d11] 09
                    ld        c,l                           ;[0d12] 4d
                    ld        b,h                           ;[0d13] 44
                    ld        hl,$0000                      ;[0d14] 21 00 00
                    add       hl,sp                         ;[0d17] 39
                    ld        e,c                           ;[0d18] 59
                    ld        d,b                           ;[0d19] 50
                    ex        de,hl                         ;[0d1a] eb
                    ld        bc,$000f                      ;[0d1b] 01 0f 00
                    ldir                                    ;[0d1e] ed b0
                    ld        l,(ix-$05)                    ;[0d20] dd 6e fb
                    ld        h,(ix-$04)                    ;[0d23] dd 66 fc
                    call      _mfs_delete                   ;[0d26] cd d0 12
                    ld        hl,$000a                      ;[0d29] 21 0a 00
                    add       hl,sp                         ;[0d2c] 39
                    ld        c,(hl)                        ;[0d2d] 4e
                    inc       hl                            ;[0d2e] 23
                    ld        b,(hl)                        ;[0d2f] 46
                    ld        d,c                           ;[0d30] 51
                    ld        l,b                           ;[0d31] 68
                    ld        e,$00                         ;[0d32] 1e 00
l_save_to_disk_00103:
                    xor       a                             ;[0d34] af
                    cp        d                             ;[0d35] ba
                    sbc       l                             ;[0d36] 9d
                    jp        po,l_save_to_disk_00205       ;[0d37] e2 3c 0d
                    xor       $80                           ;[0d3a] ee 80
l_save_to_disk_00205:
                    jp        p,l_save_to_disk_00135        ;[0d3c] f2 4a 0d
                    ld        a,d                           ;[0d3f] 7a
                    add       $04                           ;[0d40] c6 04
                    ld        d,a                           ;[0d42] 57
                    ld        a,l                           ;[0d43] 7d
                    adc       $fe                           ;[0d44] ce fe
                    ld        l,a                           ;[0d46] 6f
                    inc       e                             ;[0d47] 1c
                    jr        l_save_to_disk_00103          ;[0d48] 18 ea
l_save_to_disk_00135:
                    ld        (ix-$0a),e                    ;[0d4a] dd 73 f6
                    ld        (ix-$01),$00                  ;[0d4d] dd 36 ff 00
l_save_to_disk_00113:
                    ld        a,(ix-$01)                    ;[0d51] dd 7e ff
                    sub       (ix-$0a)                      ;[0d54] dd 96 f6
                    jp        nc,l_save_to_disk_00110       ;[0d57] d2 de 0d
                    ld        a,(ix-$01)                    ;[0d5a] dd 7e ff
                    ld        (ix-$07),a                    ;[0d5d] dd 77 f9
                    ld        (ix-$06),$00                  ;[0d60] dd 36 fa 00
                    ld        a,(ix-$01)                    ;[0d64] dd 7e ff
                    or        a                             ;[0d67] b7
                    jr        z,l_save_to_disk_00107        ;[0d68] 28 4d
                    ex        de,hl                         ;[0d6a] eb
                    ld        l,(ix-$07)                    ;[0d6b] dd 6e f9
                    ld        h,(ix-$06)                    ;[0d6e] dd 66 fa
                    dec       hl                            ;[0d71] 2b
                    add       hl,hl                         ;[0d72] 29
                    push      hl                            ;[0d73] e5
                    ex        de,hl                         ;[0d74] eb
                    ld        hl,$0011                      ;[0d75] 21 11 00
                    add       hl,sp                         ;[0d78] 39
                    add       hl,de                         ;[0d79] 19
                    pop       de                            ;[0d7a] d1
                    ld        (ix-$03),l                    ;[0d7b] dd 75 fd
                    ld        (ix-$02),h                    ;[0d7e] dd 74 fe
                    ld        e,(hl)                        ;[0d81] 5e
                    inc       hl                            ;[0d82] 23
                    ld        d,(hl)                        ;[0d83] 56
                    push      bc                            ;[0d84] c5
                    ld        a,$01                         ;[0d85] 3e 01
                    push      af                            ;[0d87] f5
                    inc       sp                            ;[0d88] 33
                    push      de                            ;[0d89] d5
                    ld        hl,$0094                      ;[0d8a] 21 94 00
                    add       hl,sp                         ;[0d8d] 39
                    push      hl                            ;[0d8e] e5
                    call      _disk_read                    ;[0d8f] cd 6f 13
                    pop       af                            ;[0d92] f1
                    pop       af                            ;[0d93] f1
                    inc       sp                            ;[0d94] 33
                    pop       bc                            ;[0d95] c1
                    ld        hl,$008f                      ;[0d96] 21 8f 00
                    add       hl,sp                         ;[0d99] 39
                    ld        (hl),$01                      ;[0d9a] 36 01
                    ld        l,(ix-$03)                    ;[0d9c] dd 6e fd
                    ld        h,(ix-$02)                    ;[0d9f] dd 66 fe
                    ld        e,(hl)                        ;[0da2] 5e
                    inc       hl                            ;[0da3] 23
                    ld        d,(hl)                        ;[0da4] 56
                    push      bc                            ;[0da5] c5
                    ld        a,$01                         ;[0da6] 3e 01
                    push      af                            ;[0da8] f5
                    inc       sp                            ;[0da9] 33
                    push      de                            ;[0daa] d5
                    ld        hl,$0094                      ;[0dab] 21 94 00
                    add       hl,sp                         ;[0dae] 39
                    push      hl                            ;[0daf] e5
                    call      _disk_write                   ;[0db0] cd 92 13
                    pop       af                            ;[0db3] f1
                    pop       af                            ;[0db4] f1
                    inc       sp                            ;[0db5] 33
                    pop       bc                            ;[0db6] c1
l_save_to_disk_00107:
                    ld        l,(ix-$07)                    ;[0db7] dd 6e f9
                    ld        h,$00                         ;[0dba] 26 00
                    add       hl,hl                         ;[0dbc] 29
                    ex        de,hl                         ;[0dbd] eb
                    ld        hl,$000f                      ;[0dbe] 21 0f 00
                    add       hl,sp                         ;[0dc1] 39
                    add       hl,de                         ;[0dc2] 19
                    push      hl                            ;[0dc3] e5
                    push      bc                            ;[0dc4] c5
                    call      _find_free_block              ;[0dc5] cd 0a 0a
                    ex        de,hl                         ;[0dc8] eb
                    pop       bc                            ;[0dc9] c1
                    pop       hl                            ;[0dca] e1
                    ld        (hl),e                        ;[0dcb] 73
                    inc       hl                            ;[0dcc] 23
                    ld        a,d                           ;[0dcd] 7a
                    ld        (hl),a                        ;[0dce] 77
                    or        e                             ;[0dcf] b3
                    jr        nz,l_save_to_disk_00114       ;[0dd0] 20 06
                    ld        hl,$ffff                      ;[0dd2] 21 ff ff
                    jp        l_save_to_disk_00118          ;[0dd5] c3 08 0f
l_save_to_disk_00114:
                    inc       (ix-$01)                      ;[0dd8] dd 34 ff
                    jp        l_save_to_disk_00113          ;[0ddb] c3 51 0d
l_save_to_disk_00110:
                    xor       a                             ;[0dde] af
                    ld        (ix-$03),a                    ;[0ddf] dd 77 fd
                    ld        (ix-$02),a                    ;[0de2] dd 77 fe
                    ld        hl,$000f                      ;[0de5] 21 0f 00
                    add       hl,sp                         ;[0de8] 39
                    ld        e,(hl)                        ;[0de9] 5e
                    inc       hl                            ;[0dea] 23
                    ld        d,(hl)                        ;[0deb] 56
                    ld        hl,$000d                      ;[0dec] 21 0d 00
                    add       hl,sp                         ;[0def] 39
                    ld        (hl),e                        ;[0df0] 73
                    inc       hl                            ;[0df1] 23
                    ld        (hl),d                        ;[0df2] 72
                    dec       hl                            ;[0df3] 2b
                    dec       hl                            ;[0df4] 2b
                    ld        (hl),$00                      ;[0df5] 36 00
                    ld        (ix-$01),$00                  ;[0df7] dd 36 ff 00
l_save_to_disk_00116:
                    ld        a,(ix-$01)                    ;[0dfb] dd 7e ff
                    sub       (ix-$0a)                      ;[0dfe] dd 96 f6
                    jp        nc,l_save_to_disk_00111       ;[0e01] d2 d4 0e
                    ld        a,$fc                         ;[0e04] 3e fc
                    cp        c                             ;[0e06] b9
                    ld        a,$01                         ;[0e07] 3e 01
                    sbc       b                             ;[0e09] 98
                    jp        po,l_save_to_disk_00206       ;[0e0a] e2 0f 0e
                    xor       $80                           ;[0e0d] ee 80
l_save_to_disk_00206:
                    jp        p,l_save_to_disk_00120        ;[0e0f] f2 17 0e
                    ld        de,$01fc                      ;[0e12] 11 fc 01
                    jr        l_save_to_disk_00121          ;[0e15] 18 02
l_save_to_disk_00120:
                    ld        e,c                           ;[0e17] 59
                    ld        d,b                           ;[0e18] 50
l_save_to_disk_00121:
                    ld        (ix-$09),e                    ;[0e19] dd 73 f7
                    ld        (ix-$08),d                    ;[0e1c] dd 72 f8
                    push      bc                            ;[0e1f] c5
                    ld        hl,$0091                      ;[0e20] 21 91 00
                    add       hl,sp                         ;[0e23] 39
                    ld        (hl),$00                      ;[0e24] 36 00
                    ld        e,l                           ;[0e26] 5d
                    ld        d,h                           ;[0e27] 54
                    inc       de                            ;[0e28] 13
                    ld        bc,$01ff                      ;[0e29] 01 ff 01
                    ldir                                    ;[0e2c] ed b0
                    pop       bc                            ;[0e2e] c1
                    ld        hl,$008f                      ;[0e2f] 21 8f 00
                    add       hl,sp                         ;[0e32] 39
                    ld        (hl),$01                      ;[0e33] 36 01
                    ld        e,(ix-$0a)                    ;[0e35] dd 5e f6
                    ld        d,$00                         ;[0e38] 16 00
                    dec       de                            ;[0e3a] 1b
                    ld        a,(ix-$01)                    ;[0e3b] dd 7e ff
                    ld        (ix-$07),a                    ;[0e3e] dd 77 f9
                    ld        (ix-$06),$00                  ;[0e41] dd 36 fa 00
                    sub       e                             ;[0e45] 93
                    ld        a,$00                         ;[0e46] 3e 00
                    sbc       d                             ;[0e48] 9a
                    jp        po,l_save_to_disk_00207       ;[0e49] e2 4e 0e
                    xor       $80                           ;[0e4c] ee 80
l_save_to_disk_00207:
                    jp        p,l_save_to_disk_00122        ;[0e4e] f2 64 0e
                    ld        e,(ix-$07)                    ;[0e51] dd 5e f9
                    ld        d,$00                         ;[0e54] 16 00
                    ex        de,hl                         ;[0e56] eb
                    inc       hl                            ;[0e57] 23
                    add       hl,hl                         ;[0e58] 29
                    ex        de,hl                         ;[0e59] eb
                    ld        hl,$000f                      ;[0e5a] 21 0f 00
                    add       hl,sp                         ;[0e5d] 39
                    add       hl,de                         ;[0e5e] 19
                    ld        e,(hl)                        ;[0e5f] 5e
                    inc       hl                            ;[0e60] 23
                    ld        d,(hl)                        ;[0e61] 56
                    jr        l_save_to_disk_00123          ;[0e62] 18 03
l_save_to_disk_00122:
                    ld        de,$0000                      ;[0e64] 11 00 00
l_save_to_disk_00123:
                    ld        hl,$0090                      ;[0e67] 21 90 00
                    add       hl,sp                         ;[0e6a] 39
                    ld        (hl),e                        ;[0e6b] 73
                    inc       hl                            ;[0e6c] 23
                    ld        (hl),d                        ;[0e6d] 72
                    ld        l,(ix-$03)                    ;[0e6e] dd 6e fd
                    ld        h,(ix-$02)                    ;[0e71] dd 66 fe
                    ld        de,$4020                      ;[0e74] 11 20 40
                    add       hl,de                         ;[0e77] 19
                    push      bc                            ;[0e78] c5
                    ex        de,hl                         ;[0e79] eb
                    ld        hl,$0095                      ;[0e7a] 21 95 00
                    add       hl,sp                         ;[0e7d] 39
                    ex        de,hl                         ;[0e7e] eb
                    ld        c,(ix-$09)                    ;[0e7f] dd 4e f7
                    ld        b,(ix-$08)                    ;[0e82] dd 46 f8
                    ld        a,b                           ;[0e85] 78
                    or        c                             ;[0e86] b1
                    jr        z,l_save_to_disk_00208        ;[0e87] 28 02
                    ldir                                    ;[0e89] ed b0
l_save_to_disk_00208:
                    pop       bc                            ;[0e8b] c1
                    ld        l,(ix-$07)                    ;[0e8c] dd 6e f9
                    ld        h,$00                         ;[0e8f] 26 00
                    add       hl,hl                         ;[0e91] 29
                    ex        de,hl                         ;[0e92] eb
                    ld        hl,$000f                      ;[0e93] 21 0f 00
                    add       hl,sp                         ;[0e96] 39
                    add       hl,de                         ;[0e97] 19
                    ld        e,(hl)                        ;[0e98] 5e
                    inc       hl                            ;[0e99] 23
                    ld        d,(hl)                        ;[0e9a] 56
                    ld        hl,$008f                      ;[0e9b] 21 8f 00
                    add       hl,sp                         ;[0e9e] 39
                    push      bc                            ;[0e9f] c5
                    ld        a,$01                         ;[0ea0] 3e 01
                    push      af                            ;[0ea2] f5
                    inc       sp                            ;[0ea3] 33
                    push      de                            ;[0ea4] d5
                    push      hl                            ;[0ea5] e5
                    call      _disk_write                   ;[0ea6] cd 92 13
                    pop       af                            ;[0ea9] f1
                    pop       af                            ;[0eaa] f1
                    inc       sp                            ;[0eab] 33
                    pop       bc                            ;[0eac] c1
                    ld        a,(ix-$03)                    ;[0ead] dd 7e fd
                    add       (ix-$09)                      ;[0eb0] dd 86 f7
                    ld        (ix-$03),a                    ;[0eb3] dd 77 fd
                    ld        a,(ix-$02)                    ;[0eb6] dd 7e fe
                    adc       (ix-$08)                      ;[0eb9] dd 8e f8
                    ld        (ix-$02),a                    ;[0ebc] dd 77 fe
                    ld        a,c                           ;[0ebf] 79
                    sub       (ix-$09)                      ;[0ec0] dd 96 f7
                    ld        c,a                           ;[0ec3] 4f
                    ld        a,b                           ;[0ec4] 78
                    sbc       (ix-$08)                      ;[0ec5] dd 9e f8
                    ld        b,a                           ;[0ec8] 47
                    ld        hl,$000c                      ;[0ec9] 21 0c 00
                    add       hl,sp                         ;[0ecc] 39
                    inc       (hl)                          ;[0ecd] 34
                    inc       (ix-$01)                      ;[0ece] dd 34 ff
                    jp        l_save_to_disk_00116          ;[0ed1] c3 fb 0d
l_save_to_disk_00111:
                    ld        hl,$1756                      ;[0ed4] 21 56 17
                    ld        a,(hl)                        ;[0ed7] 7e
                    add       (ix-$0c)                      ;[0ed8] dd 86 f4
                    ld        e,a                           ;[0edb] 5f
                    inc       hl                            ;[0edc] 23
                    ld        a,(hl)                        ;[0edd] 7e
                    adc       (ix-$0b)                      ;[0ede] dd 8e f5
                    ld        d,a                           ;[0ee1] 57
                    ld        hl,$0000                      ;[0ee2] 21 00 00
                    add       hl,sp                         ;[0ee5] 39
                    ld        bc,$000f                      ;[0ee6] 01 0f 00
                    ldir                                    ;[0ee9] ed b0
                    ld        hl,(_files)                   ;[0eeb] 2a 56 17
                    ld        c,(ix-$0c)                    ;[0eee] dd 4e f4
                    ld        b,(ix-$0b)                    ;[0ef1] dd 46 f5
                    add       hl,bc                         ;[0ef4] 09
                    ld        bc,$000d                      ;[0ef5] 01 0d 00
                    add       hl,bc                         ;[0ef8] 09
                    ex        de,hl                         ;[0ef9] eb
                    ld        hl,$000f                      ;[0efa] 21 0f 00
                    add       hl,sp                         ;[0efd] 39
                    ld        a,(hl)                        ;[0efe] 7e
                    inc       hl                            ;[0eff] 23
                    ld        b,(hl)                        ;[0f00] 46
                    ld        (de),a                        ;[0f01] 12
                    inc       de                            ;[0f02] 13
                    ld        a,b                           ;[0f03] 78
                    ld        (de),a                        ;[0f04] 12
                    ld        hl,$0000                      ;[0f05] 21 00 00
l_save_to_disk_00118:
                    ld        sp,ix                         ;[0f08] dd f9
                    pop       ix                            ;[0f0a] dd e1
                    ret                                     ;[0f0c] c9

_list_files:
                    push      ix                            ;[0f0d] dd e5
                    ld        ix,$0000                      ;[0f0f] dd 21 00 00
                    add       ix,sp                         ;[0f13] dd 39
                    dec       sp                            ;[0f15] 3b
                    ld        hl,$162f                      ;[0f16] 21 2f 16
                    call      _kputs                        ;[0f19] cd 5c 06
                    ld        (ix-$01),$00                  ;[0f1c] dd 36 ff 00
l_list_files_00103:
                    ld        hl,(_filecount)               ;[0f20] 2a 54 17
                    ld        a,(ix-$01)                    ;[0f23] dd 7e ff
                    sub       (hl)                          ;[0f26] 96
                    jr        nc,l_list_files_00105         ;[0f27] 30 53
                    ld        l,$0a                         ;[0f29] 2e 0a
                    call      _kputchar                     ;[0f2b] cd 8b 08
                    ld        l,(ix-$01)                    ;[0f2e] dd 6e ff
                    ld        h,$00                         ;[0f31] 26 00
                    ld        c,l                           ;[0f33] 4d
                    ld        b,h                           ;[0f34] 44
                    add       hl,hl                         ;[0f35] 29
                    add       hl,bc                         ;[0f36] 09
                    add       hl,hl                         ;[0f37] 29
                    add       hl,bc                         ;[0f38] 09
                    add       hl,hl                         ;[0f39] 29
                    add       hl,bc                         ;[0f3a] 09
                    ld        c,l                           ;[0f3b] 4d
                    ld        b,h                           ;[0f3c] 44
                    ld        hl,(_files)                   ;[0f3d] 2a 56 17
                    add       hl,bc                         ;[0f40] 09
                    ex        de,hl                         ;[0f41] eb
                    inc       de                            ;[0f42] 13
                    inc       de                            ;[0f43] 13
                    ld        hl,$1757                      ;[0f44] 21 57 17
                    push      bc                            ;[0f47] c5
                    ex        de,hl                         ;[0f48] eb
                    call      _kputs                        ;[0f49] cd 5c 06
                    ld        l,$20                         ;[0f4c] 2e 20
                    call      _kputchar                     ;[0f4e] cd 8b 08
                    pop       bc                            ;[0f51] c1
                    ld        hl,(_files)                   ;[0f52] 2a 56 17
                    add       hl,bc                         ;[0f55] 09
                    ld        de,$000a                      ;[0f56] 11 0a 00
                    add       hl,de                         ;[0f59] 19
                    ld        a,(hl)                        ;[0f5a] 7e
                    inc       hl                            ;[0f5b] 23
                    ld        h,(hl)                        ;[0f5c] 66
                    ld        l,a                           ;[0f5d] 6f
                    push      bc                            ;[0f5e] c5
                    call      _kputh                        ;[0f5f] cd fd 06
                    ld        l,$20                         ;[0f62] 2e 20
                    call      _kputchar                     ;[0f64] cd 8b 08
                    pop       bc                            ;[0f67] c1
                    ld        hl,(_files)                   ;[0f68] 2a 56 17
                    add       hl,bc                         ;[0f6b] 09
                    ld        bc,$000d                      ;[0f6c] 01 0d 00
                    add       hl,bc                         ;[0f6f] 09
                    ld        a,(hl)                        ;[0f70] 7e
                    inc       hl                            ;[0f71] 23
                    ld        h,(hl)                        ;[0f72] 66
                    ld        l,a                           ;[0f73] 6f
                    call      _kputh                        ;[0f74] cd fd 06
                    inc       (ix-$01)                      ;[0f77] dd 34 ff
                    jr        l_list_files_00103            ;[0f7a] 18 a4
l_list_files_00105:
                    inc       sp                            ;[0f7c] 33
                    pop       ix                            ;[0f7d] dd e1
                    ret                                     ;[0f7f] c9

_get_file_size:
                    call      _find_file                    ;[0f80] cd ec 0a
                    ld        a,h                           ;[0f83] 7c
                    ld        c,l                           ;[0f84] 4d
                    ld        b,a                           ;[0f85] 47
                    or        l                             ;[0f86] b5
                    jr        nz,l_get_file_size_00102      ;[0f87] 20 05
                    ld        hl,$ffff                      ;[0f89] 21 ff ff
                    jr        l_get_file_size_00103         ;[0f8c] 18 08
l_get_file_size_00102:
                    ld        hl,$000a                      ;[0f8e] 21 0a 00
                    add       hl,bc                         ;[0f91] 09
                    ld        a,(hl)                        ;[0f92] 7e
                    inc       hl                            ;[0f93] 23
                    ld        h,(hl)                        ;[0f94] 66
                    ld        l,a                           ;[0f95] 6f
l_get_file_size_00103:
                    ret                                     ;[0f96] c9

_mfs_open:
                    push      ix                            ;[0f97] dd e5
                    ld        ix,$0000                      ;[0f99] dd 21 00 00
                    add       ix,sp                         ;[0f9d] dd 39
                    ld        hl,$fff8                      ;[0f9f] 21 f8 ff
                    add       hl,sp                         ;[0fa2] 39
                    ld        sp,hl                         ;[0fa3] f9
                    ld        l,(ix+$04)                    ;[0fa4] dd 6e 04
                    ld        h,(ix+$05)                    ;[0fa7] dd 66 05
                    call      _find_file                    ;[0faa] cd ec 0a
                    ld        (ix-$02),l                    ;[0fad] dd 75 fe
                    ld        (ix-$01),h                    ;[0fb0] dd 74 ff
                    ld        a,h                           ;[0fb3] 7c
                    or        l                             ;[0fb4] b5
                    jp        nz,l_mfs_open_00112           ;[0fb5] c2 95 10
                    bit       1,(ix+$06)                    ;[0fb8] dd cb 06 4e
                    jp        z,l_mfs_open_00112            ;[0fbc] ca 95 10
                    call      _find_free_block              ;[0fbf] cd 0a 0a
                    ld        (ix-$04),l                    ;[0fc2] dd 75 fc
                    ld        (ix-$03),h                    ;[0fc5] dd 74 fd
                    ld        a,h                           ;[0fc8] 7c
                    or        l                             ;[0fc9] b5
                    jr        z,l_mfs_open_00101            ;[0fca] 28 08
                    ld        hl,(_filecount)               ;[0fcc] 2a 54 17
                    ld        a,(hl)                        ;[0fcf] 7e
                    sub       $08                           ;[0fd0] d6 08
                    jr        c,l_mfs_open_00123            ;[0fd2] 38 06
l_mfs_open_00101:
                    ld        hl,$ffff                      ;[0fd4] 21 ff ff
                    jp        l_mfs_open_00117              ;[0fd7] c3 cf 10
l_mfs_open_00123:
                    ld        c,$00                         ;[0fda] 0e 00
l_mfs_open_00115:
                    ld        b,$00                         ;[0fdc] 06 00
                    ld        l,c                           ;[0fde] 69
                    ld        h,b                           ;[0fdf] 60
                    add       hl,hl                         ;[0fe0] 29
                    add       hl,bc                         ;[0fe1] 09
                    add       hl,hl                         ;[0fe2] 29
                    add       hl,bc                         ;[0fe3] 09
                    add       hl,hl                         ;[0fe4] 29
                    add       hl,bc                         ;[0fe5] 09
                    ex        de,hl                         ;[0fe6] eb
                    ld        hl,(_files)                   ;[0fe7] 2a 56 17
                    add       hl,de                         ;[0fea] 19
                    ld        a,(hl)                        ;[0feb] 7e
                    ex        de,hl                         ;[0fec] eb
                    or        a                             ;[0fed] b7
                    jr        z,l_mfs_open_00106            ;[0fee] 28 06
                    inc       c                             ;[0ff0] 0c
                    ld        a,c                           ;[0ff1] 79
                    sub       $08                           ;[0ff2] d6 08
                    jr        c,l_mfs_open_00115            ;[0ff4] 38 e6
l_mfs_open_00106:
                    ld        a,c                           ;[0ff6] 79
                    sub       $08                           ;[0ff7] d6 08
                    jr        nz,l_mfs_open_00108           ;[0ff9] 20 06
                    ld        hl,$ffff                      ;[0ffb] 21 ff ff
                    jp        l_mfs_open_00117              ;[0ffe] c3 cf 10
l_mfs_open_00108:
                    ld        b,$00                         ;[1001] 06 00
                    ld        l,c                           ;[1003] 69
                    ld        h,b                           ;[1004] 60
                    add       hl,hl                         ;[1005] 29
                    add       hl,bc                         ;[1006] 09
                    add       hl,hl                         ;[1007] 29
                    add       hl,bc                         ;[1008] 09
                    add       hl,hl                         ;[1009] 29
                    add       hl,bc                         ;[100a] 09
                    ld        c,l                           ;[100b] 4d
                    ld        b,h                           ;[100c] 44
                    ld        hl,(_files)                   ;[100d] 2a 56 17
                    add       hl,bc                         ;[1010] 09
                    ex        de,hl                         ;[1011] eb
                    inc       de                            ;[1012] 13
                    inc       de                            ;[1013] 13
                    ld        l,(ix+$04)                    ;[1014] dd 6e 04
                    ld        h,(ix+$05)                    ;[1017] dd 66 05
                    push      bc                            ;[101a] c5
                    ld        bc,$0007                      ;[101b] 01 07 00
                    xor       a                             ;[101e] af
l_mfs_open_00173:
                    cp        (hl)                          ;[101f] be
                    ldi                                     ;[1020] ed a0
                    jp        po,l_mfs_open_00172           ;[1022] e2 2d 10
                    jr        nz,l_mfs_open_00173           ;[1025] 20 f8
l_mfs_open_00174:
                    dec       hl                            ;[1027] 2b
                    ldi                                     ;[1028] ed a0
                    jp        pe,l_mfs_open_00174           ;[102a] ea 27 10
l_mfs_open_00172:
                    pop       bc                            ;[102d] c1
                    ld        hl,(_files)                   ;[102e] 2a 56 17
                    add       hl,bc                         ;[1031] 09
                    ex        de,hl                         ;[1032] eb
                    ld        hl,$1757                      ;[1033] 21 57 17
                    ld        a,(ix+$06)                    ;[1036] dd 7e 06
                    and       $fd                           ;[1039] e6 fd
                    or        $01                           ;[103b] f6 01
                    ld        (de),a                        ;[103d] 12
                    dec       hl                            ;[103e] 2b
                    ld        a,(hl)                        ;[103f] 7e
                    add       c                             ;[1040] 81
                    ld        e,a                           ;[1041] 5f
                    inc       hl                            ;[1042] 23
                    ld        a,(hl)                        ;[1043] 7e
                    adc       b                             ;[1044] 88
                    ld        d,a                           ;[1045] 57
                    ld        hl,$000a                      ;[1046] 21 0a 00
                    add       hl,de                         ;[1049] 19
                    xor       a                             ;[104a] af
                    ld        (hl),a                        ;[104b] 77
                    inc       hl                            ;[104c] 23
                    ld        (hl),a                        ;[104d] 77
                    ld        hl,(_files)                   ;[104e] 2a 56 17
                    add       hl,bc                         ;[1051] 09
                    ld        de,$000c                      ;[1052] 11 0c 00
                    add       hl,de                         ;[1055] 19
                    ld        (hl),$00                      ;[1056] 36 00
                    ld        hl,(_files)                   ;[1058] 2a 56 17
                    add       hl,bc                         ;[105b] 09
                    ld        bc,$000d                      ;[105c] 01 0d 00
                    add       hl,bc                         ;[105f] 09
                    ld        a,(ix-$04)                    ;[1060] dd 7e fc
                    ld        (hl),a                        ;[1063] 77
                    inc       hl                            ;[1064] 23
                    ld        a,(ix-$03)                    ;[1065] dd 7e fd
                    ld        (hl),a                        ;[1068] 77
                    ld        hl,(_tempbuf)                 ;[1069] 2a 5a 17
                    ld        (hl),$00                      ;[106c] 36 00
                    ld        e,l                           ;[106e] 5d
                    ld        d,h                           ;[106f] 54
                    inc       de                            ;[1070] 13
                    ld        bc,$01ff                      ;[1071] 01 ff 01
                    ldir                                    ;[1074] ed b0
                    ld        hl,(_tempbuf)                 ;[1076] 2a 5a 17
                    ld        a,$01                         ;[1079] 3e 01
                    ld        (hl),a                        ;[107b] 77
                    push      af                            ;[107c] f5
                    inc       sp                            ;[107d] 33
                    ld        l,(ix-$04)                    ;[107e] dd 6e fc
                    ld        h,(ix-$03)                    ;[1081] dd 66 fd
                    push      hl                            ;[1084] e5
                    ld        hl,(_tempbuf)                 ;[1085] 2a 5a 17
                    push      hl                            ;[1088] e5
                    call      _disk_write                   ;[1089] cd 92 13
                    pop       af                            ;[108c] f1
                    pop       af                            ;[108d] f1
                    inc       sp                            ;[108e] 33
                    ld        hl,(_filecount)               ;[108f] 2a 54 17
                    inc       (hl)                          ;[1092] 34
                    jr        l_mfs_open_00113              ;[1093] 18 0d
l_mfs_open_00112:
                    ld        a,(ix-$01)                    ;[1095] dd 7e ff
                    or        (ix-$02)                      ;[1098] dd b6 fe
                    jr        nz,l_mfs_open_00113           ;[109b] 20 05
                    ld        hl,$ffff                      ;[109d] 21 ff ff
                    jr        l_mfs_open_00117              ;[10a0] 18 2d
l_mfs_open_00113:
                    ld        l,(ix-$02)                    ;[10a2] dd 6e fe
                    ld        h,(ix-$01)                    ;[10a5] dd 66 ff
                    inc       hl                            ;[10a8] 23
                    inc       hl                            ;[10a9] 23
                    call      _load_to_memory               ;[10aa] cd eb 0b
                    ld        (ix-$08),$04                  ;[10ad] dd 36 f8 04
                    ld        a,(ix-$02)                    ;[10b1] dd 7e fe
                    ld        (ix-$04),a                    ;[10b4] dd 77 fc
                    ld        a,(ix-$01)                    ;[10b7] dd 7e ff
                    ld        (ix-$03),a                    ;[10ba] dd 77 fd
                    ld        (ix-$07),$03                  ;[10bd] dd 36 f9 03
                    xor       a                             ;[10c1] af
                    ld        (ix-$06),a                    ;[10c2] dd 77 fa
                    ld        (ix-$05),a                    ;[10c5] dd 77 fb
                    ld        hl,$0000                      ;[10c8] 21 00 00
                    add       hl,sp                         ;[10cb] 39
                    call      _fd_create                    ;[10cc] cd a8 14
l_mfs_open_00117:
                    ld        sp,ix                         ;[10cf] dd f9
                    pop       ix                            ;[10d1] dd e1
                    ret                                     ;[10d3] c9

_mfs_close:
                    push      hl                            ;[10d4] e5
                    push      hl                            ;[10d5] e5
                    call      _fd_get                       ;[10d6] cd e5 13
                    pop       af                            ;[10d9] f1
                    pop       de                            ;[10da] d1
                    ld        a,h                           ;[10db] 7c
                    or        l                             ;[10dc] b5
                    jr        nz,l_mfs_close_00102          ;[10dd] 20 05
                    ld        hl,$ffff                      ;[10df] 21 ff ff
                    jr        l_mfs_close_00105             ;[10e2] 18 21
l_mfs_close_00102:
                    ld        c,(hl)                        ;[10e4] 4e
                    inc       hl                            ;[10e5] 23
                    inc       hl                            ;[10e6] 23
                    inc       hl                            ;[10e7] 23
                    inc       hl                            ;[10e8] 23
                    ld        a,c                           ;[10e9] 79
                    sub       $04                           ;[10ea] d6 04
                    jr        nz,l_mfs_close_00104          ;[10ec] 20 0f
                    ld        c,(hl)                        ;[10ee] 4e
                    inc       hl                            ;[10ef] 23
                    ld        b,(hl)                        ;[10f0] 46
                    dec       hl                            ;[10f1] 2b
                    inc       bc                            ;[10f2] 03
                    inc       bc                            ;[10f3] 03
                    push      hl                            ;[10f4] e5
                    push      de                            ;[10f5] d5
                    ld        l,c                           ;[10f6] 69
                    ld        h,b                           ;[10f7] 60
                    call      _save_to_disk                 ;[10f8] cd d7 0c
                    pop       de                            ;[10fb] d1
                    pop       hl                            ;[10fc] e1
l_mfs_close_00104:
                    xor       a                             ;[10fd] af
                    ld        (hl),a                        ;[10fe] 77
                    inc       hl                            ;[10ff] 23
                    ld        (hl),a                        ;[1100] 77
                    ex        de,hl                         ;[1101] eb
                    jp        _fd_close                     ;[1102] c3 4b 14
l_mfs_close_00105:
                    ret                                     ;[1105] c9

_mfs_read:
                    push      ix                            ;[1106] dd e5
                    ld        ix,$0000                      ;[1108] dd 21 00 00
                    add       ix,sp                         ;[110c] dd 39
                    ld        l,(ix+$04)                    ;[110e] dd 6e 04
                    ld        h,(ix+$05)                    ;[1111] dd 66 05
                    push      hl                            ;[1114] e5
                    call      _fd_get                       ;[1115] cd e5 13
                    pop       af                            ;[1118] f1
                    ex        de,hl                         ;[1119] eb
                    ld        a,d                           ;[111a] 7a
                    or        e                             ;[111b] b3
                    jr        nz,l_mfs_read_00102           ;[111c] 20 05
                    ld        hl,$ffff                      ;[111e] 21 ff ff
                    jr        l_mfs_read_00106              ;[1121] 18 4b
l_mfs_read_00102:
                    ld        l,e                           ;[1123] 6b
                    ld        h,d                           ;[1124] 62
                    inc       hl                            ;[1125] 23
                    ld        a,(hl)                        ;[1126] 7e
                    rrca                                    ;[1127] 0f
                    jr        nc,l_mfs_read_00103           ;[1128] 30 05
                    ld        a,(de)                        ;[112a] 1a
                    sub       $04                           ;[112b] d6 04
                    jr        z,l_mfs_read_00104            ;[112d] 28 05
l_mfs_read_00103:
                    ld        hl,$ffff                      ;[112f] 21 ff ff
                    jr        l_mfs_read_00106              ;[1132] 18 3a
l_mfs_read_00104:
                    ld        c,(ix+$06)                    ;[1134] dd 4e 06
                    ld        b,(ix+$07)                    ;[1137] dd 46 07
                    ex        de,hl                         ;[113a] eb
                    inc       hl                            ;[113b] 23
                    inc       hl                            ;[113c] 23
                    ld        a,(hl)                        ;[113d] 7e
                    inc       hl                            ;[113e] 23
                    ld        e,(hl)                        ;[113f] 5e
                    dec       hl                            ;[1140] 2b
                    add       $20                           ;[1141] c6 20
                    ld        d,a                           ;[1143] 57
                    ld        a,e                           ;[1144] 7b
                    adc       $40                           ;[1145] ce 40
                    push      hl                            ;[1147] e5
                    ld        e,c                           ;[1148] 59
                    ld        l,d                           ;[1149] 6a
                    ld        d,b                           ;[114a] 50
                    ld        h,a                           ;[114b] 67
                    ld        c,(ix+$08)                    ;[114c] dd 4e 08
                    ld        b,(ix+$09)                    ;[114f] dd 46 09
                    ld        a,b                           ;[1152] 78
                    or        c                             ;[1153] b1
                    jr        z,l_mfs_read_00124            ;[1154] 28 02
                    ldir                                    ;[1156] ed b0
l_mfs_read_00124:
                    pop       hl                            ;[1158] e1
                    ld        a,(hl)                        ;[1159] 7e
                    inc       hl                            ;[115a] 23
                    ld        c,(hl)                        ;[115b] 4e
                    dec       hl                            ;[115c] 2b
                    add       (ix+$08)                      ;[115d] dd 86 08
                    ld        b,a                           ;[1160] 47
                    ld        a,c                           ;[1161] 79
                    adc       (ix+$09)                      ;[1162] dd 8e 09
                    ld        (hl),b                        ;[1165] 70
                    inc       hl                            ;[1166] 23
                    ld        (hl),a                        ;[1167] 77
                    ld        l,(ix+$08)                    ;[1168] dd 6e 08
                    ld        h,(ix+$09)                    ;[116b] dd 66 09
l_mfs_read_00106:
                    pop       ix                            ;[116e] dd e1
                    ret                                     ;[1170] c9

_mfs_write:
                    push      ix                            ;[1171] dd e5
                    ld        ix,$0000                      ;[1173] dd 21 00 00
                    add       ix,sp                         ;[1177] dd 39
                    push      af                            ;[1179] f5
                    ld        l,(ix+$04)                    ;[117a] dd 6e 04
                    ld        h,(ix+$05)                    ;[117d] dd 66 05
                    push      hl                            ;[1180] e5
                    call      _fd_get                       ;[1181] cd e5 13
                    pop       af                            ;[1184] f1
                    ld        a,h                           ;[1185] 7c
                    or        l                             ;[1186] b5
                    ld        c,l                           ;[1187] 4d
                    ld        b,h                           ;[1188] 44
                    jr        nz,l_mfs_write_00102          ;[1189] 20 05
                    ld        hl,$ffff                      ;[118b] 21 ff ff
                    jr        l_mfs_write_00108             ;[118e] 18 6b
l_mfs_write_00102:
                    ld        l,c                           ;[1190] 69
                    ld        h,b                           ;[1191] 60
                    inc       hl                            ;[1192] 23
                    bit       1,(hl)                        ;[1193] cb 4e
                    jr        z,l_mfs_write_00103           ;[1195] 28 05
                    ld        a,(bc)                        ;[1197] 0a
                    sub       $04                           ;[1198] d6 04
                    jr        z,l_mfs_write_00104           ;[119a] 28 05
l_mfs_write_00103:
                    ld        hl,$ffff                      ;[119c] 21 ff ff
                    jr        l_mfs_write_00108             ;[119f] 18 5a
l_mfs_write_00104:
                    ld        hl,$0002                      ;[11a1] 21 02 00
                    add       hl,bc                         ;[11a4] 09
                    pop       af                            ;[11a5] f1
                    ld        e,(hl)                        ;[11a6] 5e
                    push      hl                            ;[11a7] e5
                    inc       hl                            ;[11a8] 23
                    ld        d,(hl)                        ;[11a9] 56
                    ld        hl,$4020                      ;[11aa] 21 20 40
                    add       hl,de                         ;[11ad] 19
                    ex        de,hl                         ;[11ae] eb
                    ld        l,(ix+$06)                    ;[11af] dd 6e 06
                    ld        h,(ix+$07)                    ;[11b2] dd 66 07
                    push      bc                            ;[11b5] c5
                    ld        c,(ix+$08)                    ;[11b6] dd 4e 08
                    ld        b,(ix+$09)                    ;[11b9] dd 46 09
                    ld        a,b                           ;[11bc] 78
                    or        c                             ;[11bd] b1
                    jr        z,l_mfs_write_00133           ;[11be] 28 02
                    ldir                                    ;[11c0] ed b0
l_mfs_write_00133:
                    pop       bc                            ;[11c2] c1
                    pop       hl                            ;[11c3] e1
                    ld        a,(hl)                        ;[11c4] 7e
                    push      hl                            ;[11c5] e5
                    inc       hl                            ;[11c6] 23
                    ld        d,(hl)                        ;[11c7] 56
                    add       (ix+$08)                      ;[11c8] dd 86 08
                    ld        e,a                           ;[11cb] 5f
                    ld        a,d                           ;[11cc] 7a
                    adc       (ix+$09)                      ;[11cd] dd 8e 09
                    ld        d,a                           ;[11d0] 57
                    pop       hl                            ;[11d1] e1
                    push      hl                            ;[11d2] e5
                    ld        (hl),e                        ;[11d3] 73
                    inc       hl                            ;[11d4] 23
                    ld        (hl),d                        ;[11d5] 72
                    ld        hl,$0004                      ;[11d6] 21 04 00
                    add       hl,bc                         ;[11d9] 09
                    ld        c,(hl)                        ;[11da] 4e
                    inc       hl                            ;[11db] 23
                    ld        b,(hl)                        ;[11dc] 46
                    ld        hl,$000a                      ;[11dd] 21 0a 00
                    add       hl,bc                         ;[11e0] 09
                    ld        a,(hl)                        ;[11e1] 7e
                    ld        c,l                           ;[11e2] 4d
                    ld        b,h                           ;[11e3] 44
                    inc       hl                            ;[11e4] 23
                    ld        h,(hl)                        ;[11e5] 66
                    ld        l,a                           ;[11e6] 6f
                    xor       a                             ;[11e7] af
                    sbc       hl,de                         ;[11e8] ed 52
                    jr        nc,l_mfs_write_00107          ;[11ea] 30 09
                    pop       hl                            ;[11ec] e1
                    ld        a,(hl)                        ;[11ed] 7e
                    push      hl                            ;[11ee] e5
                    inc       hl                            ;[11ef] 23
                    ld        d,(hl)                        ;[11f0] 56
                    ld        (bc),a                        ;[11f1] 02
                    inc       bc                            ;[11f2] 03
                    ld        a,d                           ;[11f3] 7a
                    ld        (bc),a                        ;[11f4] 02
l_mfs_write_00107:
                    ld        l,(ix+$08)                    ;[11f5] dd 6e 08
                    ld        h,(ix+$09)                    ;[11f8] dd 66 09
l_mfs_write_00108:
                    ld        sp,ix                         ;[11fb] dd f9
                    pop       ix                            ;[11fd] dd e1
                    ret                                     ;[11ff] c9

_mfs_sync:
                    ld        a,$01                         ;[1200] 3e 01
                    push      af                            ;[1202] f5
                    inc       sp                            ;[1203] 33
                    ld        hl,$0000                      ;[1204] 21 00 00
                    push      hl                            ;[1207] e5
                    ld        hl,(_fs_rootfs)               ;[1208] 2a 58 17
                    push      hl                            ;[120b] e5
                    call      _disk_write                   ;[120c] cd 92 13
                    pop       af                            ;[120f] f1
                    pop       af                            ;[1210] f1
                    inc       sp                            ;[1211] 33
                    ld        hl,$0000                      ;[1212] 21 00 00
                    ret                                     ;[1215] c9

_mfs_seek:
                    push      ix                            ;[1216] dd e5
                    ld        ix,$0000                      ;[1218] dd 21 00 00
                    add       ix,sp                         ;[121c] dd 39
                    ld        l,(ix+$04)                    ;[121e] dd 6e 04
                    ld        h,(ix+$05)                    ;[1221] dd 66 05
                    push      hl                            ;[1224] e5
                    call      _fd_get                       ;[1225] cd e5 13
                    pop       af                            ;[1228] f1
                    ld        a,h                           ;[1229] 7c
                    or        l                             ;[122a] b5
                    jr        nz,l_mfs_seek_00102           ;[122b] 20 05
                    ld        hl,$ffff                      ;[122d] 21 ff ff
                    jr        l_mfs_seek_00105              ;[1230] 18 18
l_mfs_seek_00102:
                    ld        a,(hl)                        ;[1232] 7e
                    sub       $04                           ;[1233] d6 04
                    jr        z,l_mfs_seek_00104            ;[1235] 28 05
                    ld        hl,$ffff                      ;[1237] 21 ff ff
                    jr        l_mfs_seek_00105              ;[123a] 18 0e
l_mfs_seek_00104:
                    inc       hl                            ;[123c] 23
                    inc       hl                            ;[123d] 23
                    ld        a,(ix+$06)                    ;[123e] dd 7e 06
                    ld        (hl),a                        ;[1241] 77
                    inc       hl                            ;[1242] 23
                    ld        a,(ix+$07)                    ;[1243] dd 7e 07
                    ld        (hl),a                        ;[1246] 77
                    ld        hl,$0000                      ;[1247] 21 00 00
l_mfs_seek_00105:
                    pop       ix                            ;[124a] dd e1
                    ret                                     ;[124c] c9

_dump_fs:
                    ld        hl,$163b                      ;[124d] 21 3b 16
                    call      _kputs                        ;[1250] cd 5c 06
                    ld        hl,$1653                      ;[1253] 21 53 16
                    call      _kputs                        ;[1256] cd 5c 06
                    ld        hl,(_checksum)                ;[1259] 2a 50 17
                    ld        e,(hl)                        ;[125c] 5e
                    inc       hl                            ;[125d] 23
                    ld        d,(hl)                        ;[125e] 56
                    ex        de,hl                         ;[125f] eb
                    call      _kputh                        ;[1260] cd fd 06
                    ld        hl,$165e                      ;[1263] 21 5e 16
                    call      _kputs                        ;[1266] cd 5c 06
                    ld        hl,$1660                      ;[1269] 21 60 16
                    call      _kputs                        ;[126c] cd 5c 06
                    ld        hl,(_formatted)               ;[126f] 2a 52 17
                    ld        l,(hl)                        ;[1272] 6e
                    ld        h,$00                         ;[1273] 26 00
                    call      _kputh                        ;[1275] cd fd 06
                    ld        hl,$165e                      ;[1278] 21 5e 16
                    call      _kputs                        ;[127b] cd 5c 06
                    ld        hl,$166c                      ;[127e] 21 6c 16
                    call      _kputs                        ;[1281] cd 5c 06
                    ld        hl,(_filecount)               ;[1284] 2a 54 17
                    ld        l,(hl)                        ;[1287] 6e
                    ld        h,$00                         ;[1288] 26 00
                    call      _kputh                        ;[128a] cd fd 06
                    ld        hl,$165e                      ;[128d] 21 5e 16
                    call      _kputs                        ;[1290] cd 5c 06
                    ld        hl,$1678                      ;[1293] 21 78 16
                    call      _kputs                        ;[1296] cd 5c 06
                    ld        c,$00                         ;[1299] 0e 00
l_dump_fs_00103:
                    ld        hl,(_filecount)               ;[129b] 2a 54 17
                    ld        b,(hl)                        ;[129e] 46
                    ld        a,c                           ;[129f] 79
                    sub       b                             ;[12a0] 90
                    jr        nc,l_dump_fs_00101            ;[12a1] 30 23
                    ld        b,$00                         ;[12a3] 06 00
                    ld        l,c                           ;[12a5] 69
                    ld        h,b                           ;[12a6] 60
                    add       hl,hl                         ;[12a7] 29
                    add       hl,bc                         ;[12a8] 09
                    add       hl,hl                         ;[12a9] 29
                    add       hl,bc                         ;[12aa] 09
                    add       hl,hl                         ;[12ab] 29
                    add       hl,bc                         ;[12ac] 09
                    ex        de,hl                         ;[12ad] eb
                    ld        hl,(_files)                   ;[12ae] 2a 56 17
                    add       hl,de                         ;[12b1] 19
                    ex        de,hl                         ;[12b2] eb
                    inc       de                            ;[12b3] 13
                    inc       de                            ;[12b4] 13
                    ld        hl,$1757                      ;[12b5] 21 57 17
                    push      bc                            ;[12b8] c5
                    ex        de,hl                         ;[12b9] eb
                    call      _kputs                        ;[12ba] cd 5c 06
                    ld        l,$20                         ;[12bd] 2e 20
                    call      _kputchar                     ;[12bf] cd 8b 08
                    pop       bc                            ;[12c2] c1
                    inc       c                             ;[12c3] 0c
                    jr        l_dump_fs_00103               ;[12c4] 18 d5
l_dump_fs_00101:
                    ld        hl,$165e                      ;[12c6] 21 5e 16
                    call      _kputs                        ;[12c9] cd 5c 06
                    ld        hl,$0000                      ;[12cc] 21 00 00
                    ret                                     ;[12cf] c9

_mfs_delete:
                    push      ix                            ;[12d0] dd e5
                    ld        ix,$0000                      ;[12d2] dd 21 00 00
                    add       ix,sp                         ;[12d6] dd 39
                    ld        c,l                           ;[12d8] 4d
                    ld        b,h                           ;[12d9] 44
                    ld        hl,$fdfe                      ;[12da] 21 fe fd
                    add       hl,sp                         ;[12dd] 39
                    ld        sp,hl                         ;[12de] f9
                    ld        l,c                           ;[12df] 69
                    ld        h,b                           ;[12e0] 60
                    call      _find_file                    ;[12e1] cd ec 0a
                    ld        a,h                           ;[12e4] 7c
                    or        l                             ;[12e5] b5
                    ld        c,l                           ;[12e6] 4d
                    ld        b,h                           ;[12e7] 44
                    jr        nz,l_mfs_delete_00102         ;[12e8] 20 06
                    ld        hl,$ffff                      ;[12ea] 21 ff ff
                    jp        l_mfs_delete_00107            ;[12ed] c3 6a 13
l_mfs_delete_00102:
                    ld        hl,$000d                      ;[12f0] 21 0d 00
                    add       hl,bc                         ;[12f3] 09
                    ld        (ix-$02),l                    ;[12f4] dd 75 fe
                    ld        (ix-$01),h                    ;[12f7] dd 74 ff
                    ld        e,(hl)                        ;[12fa] 5e
                    inc       hl                            ;[12fb] 23
                    ld        d,(hl)                        ;[12fc] 56
                    push      de                            ;[12fd] d5
                    push      bc                            ;[12fe] c5
                    ld        hl,$0004                      ;[12ff] 21 04 00
                    add       hl,sp                         ;[1302] 39
                    ld        (hl),$00                      ;[1303] 36 00
                    ld        e,l                           ;[1305] 5d
                    ld        d,h                           ;[1306] 54
                    inc       de                            ;[1307] 13
                    ld        bc,$01ff                      ;[1308] 01 ff 01
                    ldir                                    ;[130b] ed b0
                    pop       bc                            ;[130d] c1
                    pop       de                            ;[130e] d1
l_mfs_delete_00104:
                    ld        a,d                           ;[130f] 7a
                    or        e                             ;[1310] b3
                    jr        z,l_mfs_delete_00106          ;[1311] 28 3a
                    ld        a,e                           ;[1313] 7b
                    sub       $ff                           ;[1314] d6 ff
                    ld        a,d                           ;[1316] 7a
                    sbc       $00                           ;[1317] de 00
                    jr        nc,l_mfs_delete_00106         ;[1319] 30 32
                    push      bc                            ;[131b] c5
                    push      de                            ;[131c] d5
                    ld        a,$01                         ;[131d] 3e 01
                    push      af                            ;[131f] f5
                    inc       sp                            ;[1320] 33
                    ld        hl,(_tempbuf)                 ;[1321] 2a 5a 17
                    push      de                            ;[1324] d5
                    push      hl                            ;[1325] e5
                    call      _disk_read                    ;[1326] cd 6f 13
                    pop       af                            ;[1329] f1
                    pop       af                            ;[132a] f1
                    inc       sp                            ;[132b] 33
                    pop       de                            ;[132c] d1
                    pop       bc                            ;[132d] c1
                    ld        hl,(_tempbuf)                 ;[132e] 2a 5a 17
                    inc       hl                            ;[1331] 23
                    ld        a,(hl)                        ;[1332] 7e
                    inc       hl                            ;[1333] 23
                    ld        h,(hl)                        ;[1334] 66
                    ld        l,a                           ;[1335] 6f
                    push      hl                            ;[1336] e5
                    push      bc                            ;[1337] c5
                    ld        a,$01                         ;[1338] 3e 01
                    push      af                            ;[133a] f5
                    inc       sp                            ;[133b] 33
                    push      de                            ;[133c] d5
                    ld        hl,$0007                      ;[133d] 21 07 00
                    add       hl,sp                         ;[1340] 39
                    push      hl                            ;[1341] e5
                    call      _disk_write                   ;[1342] cd 92 13
                    pop       af                            ;[1345] f1
                    pop       af                            ;[1346] f1
                    inc       sp                            ;[1347] 33
                    pop       bc                            ;[1348] c1
                    pop       hl                            ;[1349] e1
                    ex        de,hl                         ;[134a] eb
                    jr        l_mfs_delete_00104            ;[134b] 18 c2
l_mfs_delete_00106:
                    xor       a                             ;[134d] af
                    ld        (bc),a                        ;[134e] 02
                    ld        hl,$000a                      ;[134f] 21 0a 00
                    add       hl,bc                         ;[1352] 09
                    xor       a                             ;[1353] af
                    ld        (hl),a                        ;[1354] 77
                    inc       hl                            ;[1355] 23
                    ld        (hl),a                        ;[1356] 77
                    ld        l,(ix-$02)                    ;[1357] dd 6e fe
                    ld        h,(ix-$01)                    ;[135a] dd 66 ff
                    xor       a                             ;[135d] af
                    ld        (hl),a                        ;[135e] 77
                    inc       hl                            ;[135f] 23
                    ld        (hl),a                        ;[1360] 77
                    ld        hl,$000c                      ;[1361] 21 0c 00
                    add       hl,bc                         ;[1364] 09
                    ld        (hl),$00                      ;[1365] 36 00
                    ld        hl,$0000                      ;[1367] 21 00 00
l_mfs_delete_00107:
                    ld        sp,ix                         ;[136a] dd f9
                    pop       ix                            ;[136c] dd e1
                    ret                                     ;[136e] c9

_disk_read:
                    push      ix                            ;[136f] dd e5
                    ld        ix,$0000                      ;[1371] dd 21 00 00
                    add       ix,sp                         ;[1375] dd 39
                    ld        a,(ix+$08)                    ;[1377] dd 7e 08
                    ld        e,(ix+$06)                    ;[137a] dd 5e 06
                    ld        d,(ix+$07)                    ;[137d] dd 56 07
                    ld        l,(ix+$04)                    ;[1380] dd 6e 04
                    ld        h,(ix+$05)                    ;[1383] dd 66 05
                    call      READ_DISK                     ;[1386] cd c5 00
                    ld        l,a                           ;[1389] 6f
                    ld        h,$00                         ;[138a] 26 00
                    pop       ix                            ;[138c] dd e1
                    ret                                     ;[138e] c9

                    ld        hl,$0000                      ;[138f] 21 00 00
_disk_write:
                    push      ix                            ;[1392] dd e5
                    ld        ix,$0000                      ;[1394] dd 21 00 00
                    add       ix,sp                         ;[1398] dd 39
                    ld        a,(ix+$08)                    ;[139a] dd 7e 08
                    ld        e,(ix+$06)                    ;[139d] dd 5e 06
                    ld        d,(ix+$07)                    ;[13a0] dd 56 07
                    ld        l,(ix+$04)                    ;[13a3] dd 6e 04
                    ld        h,(ix+$05)                    ;[13a6] dd 66 05
                    call      WRITE_DISK                    ;[13a9] cd af 00
                    ld        l,a                           ;[13ac] 6f
                    ld        h,$00                         ;[13ad] 26 00
                    pop       ix                            ;[13af] dd e1
                    ret                                     ;[13b1] c9

                    ld        hl,$0000                      ;[13b2] 21 00 00
_fd_init:
                    ld        b,$30                         ;[13b5] 06 30
                    ld        hl,$2a8e                      ;[13b7] 21 8e 2a
l_fd_init_00103:
                    ld        (hl),$00                      ;[13ba] 36 00
                    inc       hl                            ;[13bc] 23
                    djnz      l_fd_init_00103               ;[13bd] 10 fb
                    ld        hl,$2abe                      ;[13bf] 21 be 2a
                    ld        (hl),$03                      ;[13c2] 36 03
                    xor       a                             ;[13c4] af
                    inc       hl                            ;[13c5] 23
                    ld        (hl),a                        ;[13c6] 77
                    ld        hl,$0101                      ;[13c7] 21 01 01
                    ld        (_fd_table),hl                ;[13ca] 22 8e 2a
                    ld        hl,$2a94                      ;[13cd] 21 94 2a
                    ld        (hl),$02                      ;[13d0] 36 02
                    ld        hl,$2a95                      ;[13d2] 21 95 2a
                    ld        (hl),$02                      ;[13d5] 36 02
                    ld        hl,$2a9a                      ;[13d7] 21 9a 2a
                    ld        (hl),$03                      ;[13da] 36 03
                    ld        hl,$2a9b                      ;[13dc] 21 9b 2a
                    ld        (hl),$02                      ;[13df] 36 02
                    ld        hl,$0000                      ;[13e1] 21 00 00
                    ret                                     ;[13e4] c9

_fd_get:
                    push      ix                            ;[13e5] dd e5
                    ld        ix,$0000                      ;[13e7] dd 21 00 00
                    add       ix,sp                         ;[13eb] dd 39
                    bit       7,(ix+$05)                    ;[13ed] dd cb 05 7e
                    jr        nz,l_fd_get_00101             ;[13f1] 20 0f
                    ld        a,(ix+$04)                    ;[13f3] dd 7e 04
                    sub       $08                           ;[13f6] d6 08
                    ld        a,(ix+$05)                    ;[13f8] dd 7e 05
                    rla                                     ;[13fb] 17
                    ccf                                     ;[13fc] 3f
                    rra                                     ;[13fd] 1f
                    sbc       $80                           ;[13fe] de 80
                    jr        c,l_fd_get_00102              ;[1400] 38 05
l_fd_get_00101:
                    ld        hl,$0000                      ;[1402] 21 00 00
                    jr        l_fd_get_00106                ;[1405] 18 1d
l_fd_get_00102:
                    ld        a,(ix+$04)                    ;[1407] dd 7e 04
                    and       (ix+$05)                      ;[140a] dd a6 05
                    inc       a                             ;[140d] 3c
                    jr        nz,l_fd_get_00105             ;[140e] 20 05
                    ld        hl,$0000                      ;[1410] 21 00 00
                    jr        l_fd_get_00106                ;[1413] 18 0f
l_fd_get_00105:
                    ld        bc,$2a8e                      ;[1415] 01 8e 2a
                    ld        l,(ix+$04)                    ;[1418] dd 6e 04
                    ld        h,(ix+$05)                    ;[141b] dd 66 05
                    ld        e,l                           ;[141e] 5d
                    ld        d,h                           ;[141f] 54
                    add       hl,hl                         ;[1420] 29
                    add       hl,de                         ;[1421] 19
                    add       hl,hl                         ;[1422] 29
                    add       hl,bc                         ;[1423] 09
l_fd_get_00106:
                    pop       ix                            ;[1424] dd e1
                    ret                                     ;[1426] c9

_fd_alloc:
                    ld        bc,$0000                      ;[1427] 01 00 00
l_fd_alloc_00105:
                    ld        a,b                           ;[142a] 78
                    sub       $08                           ;[142b] d6 08
                    jr        nc,l_fd_alloc_00103           ;[142d] 30 18
                    ld        e,b                           ;[142f] 58
                    ld        d,$00                         ;[1430] 16 00
                    ld        l,e                           ;[1432] 6b
                    ld        h,d                           ;[1433] 62
                    add       hl,hl                         ;[1434] 29
                    add       hl,de                         ;[1435] 19
                    add       hl,hl                         ;[1436] 29
                    ld        de,$2a8e                      ;[1437] 11 8e 2a
                    add       hl,de                         ;[143a] 19
                    ld        a,(hl)                        ;[143b] 7e
                    or        a                             ;[143c] b7
                    jr        nz,l_fd_alloc_00106           ;[143d] 20 04
                    ld        h,a                           ;[143f] 67
                    ld        l,c                           ;[1440] 69
                    jr        l_fd_alloc_00107              ;[1441] 18 07
l_fd_alloc_00106:
                    inc       b                             ;[1443] 04
                    ld        c,b                           ;[1444] 48
                    jr        l_fd_alloc_00105              ;[1445] 18 e3
l_fd_alloc_00103:
                    ld        hl,$ffff                      ;[1447] 21 ff ff
l_fd_alloc_00107:
                    ret                                     ;[144a] c9

_fd_close:
                    ld        a,l                           ;[144b] 7d
                    sub       $03                           ;[144c] d6 03
                    ld        a,h                           ;[144e] 7c
                    ld        c,l                           ;[144f] 4d
                    ld        b,a                           ;[1450] 47
                    rla                                     ;[1451] 17
                    ccf                                     ;[1452] 3f
                    rra                                     ;[1453] 1f
                    sbc       $80                           ;[1454] de 80
                    jr        c,l_fd_close_00101            ;[1456] 38 08
                    ld        a,c                           ;[1458] 79
                    sub       $08                           ;[1459] d6 08
                    ld        a,b                           ;[145b] 78
                    sbc       $00                           ;[145c] de 00
                    jr        c,l_fd_close_00102            ;[145e] 38 05
l_fd_close_00101:
                    ld        hl,$0001                      ;[1460] 21 01 00
                    jr        l_fd_close_00109              ;[1463] 18 42
l_fd_close_00102:
                    ld        a,c                           ;[1465] 79
                    and       b                             ;[1466] a0
                    inc       a                             ;[1467] 3c
                    jr        nz,l_fd_close_00105           ;[1468] 20 05
                    ld        hl,$ffff                      ;[146a] 21 ff ff
                    jr        l_fd_close_00109              ;[146d] 18 38
l_fd_close_00105:
                    ld        de,$2a8e                      ;[146f] 11 8e 2a
                    ld        l,c                           ;[1472] 69
                    ld        h,b                           ;[1473] 60
                    add       hl,hl                         ;[1474] 29
                    add       hl,bc                         ;[1475] 09
                    add       hl,hl                         ;[1476] 29
                    add       hl,de                         ;[1477] 19
                    ld        a,(hl)                        ;[1478] 7e
                    ex        de,hl                         ;[1479] eb
                    sub       $04                           ;[147a] d6 04
                    jr        nz,l_fd_close_00107           ;[147c] 20 14
                    ld        l,e                           ;[147e] 6b
                    ld        h,d                           ;[147f] 62
                    inc       hl                            ;[1480] 23
                    inc       hl                            ;[1481] 23
                    inc       hl                            ;[1482] 23
                    inc       hl                            ;[1483] 23
                    inc       hl                            ;[1484] 23
                    ld        a,(hl)                        ;[1485] 7e
                    dec       hl                            ;[1486] 2b
                    ld        l,(hl)                        ;[1487] 6e
                    or        l                             ;[1488] b5
                    jr        z,l_fd_close_00107            ;[1489] 28 07
                    push      de                            ;[148b] d5
                    ld        l,c                           ;[148c] 69
                    ld        h,b                           ;[148d] 60
                    call      _mfs_close                    ;[148e] cd d4 10
                    pop       de                            ;[1491] d1
l_fd_close_00107:
                    ex        de,hl                         ;[1492] eb
                    ld        b,$06                         ;[1493] 06 06
l_fd_close_00143:
                    ld        (hl),$00                      ;[1495] 36 00
                    inc       hl                            ;[1497] 23
                    djnz      l_fd_close_00143              ;[1498] 10 fb
                    ld        hl,(_fd_count)                ;[149a] 2a be 2a
                    ld        de,$ffff                      ;[149d] 11 ff ff
                    add       hl,de                         ;[14a0] 19
                    ld        (_fd_count),hl                ;[14a1] 22 be 2a
                    ld        hl,$0000                      ;[14a4] 21 00 00
l_fd_close_00109:
                    ret                                     ;[14a7] c9

_fd_create:
                    push      hl                            ;[14a8] e5
                    call      _fd_alloc                     ;[14a9] cd 27 14
                    ld        c,l                           ;[14ac] 4d
                    ld        b,h                           ;[14ad] 44
                    pop       de                            ;[14ae] d1
                    ld        a,c                           ;[14af] 79
                    and       b                             ;[14b0] a0
                    inc       a                             ;[14b1] 3c
                    jr        nz,l_fd_create_00102          ;[14b2] 20 05
                    ld        hl,$ffff                      ;[14b4] 21 ff ff
                    jr        l_fd_create_00103             ;[14b7] 18 1a
l_fd_create_00102:
                    ld        l,c                           ;[14b9] 69
                    ld        h,b                           ;[14ba] 60
                    add       hl,hl                         ;[14bb] 29
                    add       hl,bc                         ;[14bc] 09
                    add       hl,hl                         ;[14bd] 29
                    push      bc                            ;[14be] c5
                    ld        bc,$2a8e                      ;[14bf] 01 8e 2a
                    add       hl,bc                         ;[14c2] 09
                    ex        de,hl                         ;[14c3] eb
                    ld        bc,$0006                      ;[14c4] 01 06 00
                    ldir                                    ;[14c7] ed b0
                    pop       bc                            ;[14c9] c1
                    ld        hl,(_fd_count)                ;[14ca] 2a be 2a
                    inc       hl                            ;[14cd] 23
                    ld        (_fd_count),hl                ;[14ce] 22 be 2a
                    ld        l,c                           ;[14d1] 69
                    ld        h,b                           ;[14d2] 60
l_fd_create_00103:
                    ret                                     ;[14d3] c9

                    defb      $00                           ;[14d4] 00
___str_0_kernel_c:
                    defb      $4d                           ;[14d5] 4d
                    defb      $61                           ;[14d6] 61
                    defb      $6e                           ;[14d7] 6e
                    defb      $75                           ;[14d8] 75
                    defb      $78                           ;[14d9] 78
                    defb      $20                           ;[14da] 20
                    defb      $4b                           ;[14db] 4b
                    defb      $65                           ;[14dc] 65
                    defb      $72                           ;[14dd] 72
                    defb      $6e                           ;[14de] 6e
                    defb      $65                           ;[14df] 65
                    defb      $6c                           ;[14e0] 6c
                    defb      $0a                           ;[14e1] 0a
                    defb      $00                           ;[14e2] 00
___str_1_kernel_c:
                    defb      $20                           ;[14e3] 20
                    defb      $46                           ;[14e4] 46
                    defb      $69                           ;[14e5] 69
                    defb      $6c                           ;[14e6] 6c
                    defb      $65                           ;[14e7] 65
                    defb      $73                           ;[14e8] 73
                    defb      $79                           ;[14e9] 79
                    defb      $73                           ;[14ea] 73
                    defb      $74                           ;[14eb] 74
                    defb      $65                           ;[14ec] 65
                    defb      $6d                           ;[14ed] 6d
                    defb      $20                           ;[14ee] 20
                    defb      $69                           ;[14ef] 69
                    defb      $6e                           ;[14f0] 6e
                    defb      $69                           ;[14f1] 69
                    defb      $74                           ;[14f2] 74
                    defb      $20                           ;[14f3] 20
                    defb      $66                           ;[14f4] 66
                    defb      $61                           ;[14f5] 61
                    defb      $69                           ;[14f6] 69
                    defb      $6c                           ;[14f7] 6c
                    defb      $65                           ;[14f8] 65
                    defb      $64                           ;[14f9] 64
                    defb      $0a                           ;[14fa] 0a
                    defb      $00                           ;[14fb] 00
___str_2_kernel_c:
                    defb      $20                           ;[14fc] 20
                    defb      $46                           ;[14fd] 46
                    defb      $53                           ;[14fe] 53
                    defb      $20                           ;[14ff] 20
                    defb      $69                           ;[1500] 69
                    defb      $6e                           ;[1501] 6e
                    defb      $69                           ;[1502] 69
                    defb      $74                           ;[1503] 74
                    defb      $20                           ;[1504] 20
                    defb      $64                           ;[1505] 64
                    defb      $6f                           ;[1506] 6f
                    defb      $6e                           ;[1507] 6e
                    defb      $65                           ;[1508] 65
                    defb      $0a                           ;[1509] 0a
                    defb      $00                           ;[150a] 00
___str_3_kernel_c:
                    defb      $20                           ;[150b] 20
                    defb      $46                           ;[150c] 46
                    defb      $69                           ;[150d] 69
                    defb      $6c                           ;[150e] 6c
                    defb      $65                           ;[150f] 65
                    defb      $20                           ;[1510] 20
                    defb      $64                           ;[1511] 64
                    defb      $65                           ;[1512] 65
                    defb      $73                           ;[1513] 73
                    defb      $63                           ;[1514] 63
                    defb      $72                           ;[1515] 72
                    defb      $69                           ;[1516] 69
                    defb      $70                           ;[1517] 70
                    defb      $74                           ;[1518] 74
                    defb      $6f                           ;[1519] 6f
                    defb      $72                           ;[151a] 72
                    defb      $20                           ;[151b] 20
                    defb      $69                           ;[151c] 69
                    defb      $6e                           ;[151d] 6e
                    defb      $69                           ;[151e] 69
                    defb      $74                           ;[151f] 74
                    defb      $20                           ;[1520] 20
                    defb      $66                           ;[1521] 66
                    defb      $61                           ;[1522] 61
                    defb      $69                           ;[1523] 69
                    defb      $6c                           ;[1524] 6c
                    defb      $65                           ;[1525] 65
                    defb      $64                           ;[1526] 64
                    defb      $0a                           ;[1527] 0a
                    defb      $00                           ;[1528] 00
___str_4_kernel_c:
                    defb      $20                           ;[1529] 20
                    defb      $46                           ;[152a] 46
                    defb      $44                           ;[152b] 44
                    defb      $20                           ;[152c] 20
                    defb      $69                           ;[152d] 69
                    defb      $6e                           ;[152e] 6e
                    defb      $69                           ;[152f] 69
                    defb      $74                           ;[1530] 74
                    defb      $20                           ;[1531] 20
                    defb      $64                           ;[1532] 64
                    defb      $6f                           ;[1533] 6f
                    defb      $6e                           ;[1534] 6e
                    defb      $65                           ;[1535] 65
                    defb      $0a                           ;[1536] 0a
                    defb      $00                           ;[1537] 00
___str_5_kernel_c:
                    defb      $20                           ;[1538] 20
                    defb      $52                           ;[1539] 52
                    defb      $75                           ;[153a] 75
                    defb      $6e                           ;[153b] 6e
                    defb      $6e                           ;[153c] 6e
                    defb      $69                           ;[153d] 69
                    defb      $6e                           ;[153e] 6e
                    defb      $67                           ;[153f] 67
                    defb      $20                           ;[1540] 20
                    defb      $69                           ;[1541] 69
                    defb      $6e                           ;[1542] 6e
                    defb      $69                           ;[1543] 69
                    defb      $74                           ;[1544] 74
                    defb      $2f                           ;[1545] 2f
                    defb      $73                           ;[1546] 73
                    defb      $68                           ;[1547] 68
                    defb      $65                           ;[1548] 65
                    defb      $6c                           ;[1549] 6c
                    defb      $6c                           ;[154a] 6c
                    defb      $0a                           ;[154b] 0a
                    defb      $00                           ;[154c] 00
___str_6_kernel_c:
                    defb      $53                           ;[154d] 53
                    defb      $48                           ;[154e] 48
                    defb      $45                           ;[154f] 45
                    defb      $4c                           ;[1550] 4c
                    defb      $4c                           ;[1551] 4c
                    defb      $53                           ;[1552] 53
                    defb      $48                           ;[1553] 48
                    defb      $00                           ;[1554] 00
___str_7_kernel_c:
                    defb      $20                           ;[1555] 20
                    defb      $53                           ;[1556] 53
                    defb      $68                           ;[1557] 68
                    defb      $65                           ;[1558] 65
                    defb      $6c                           ;[1559] 6c
                    defb      $6c                           ;[155a] 6c
                    defb      $20                           ;[155b] 20
                    defb      $69                           ;[155c] 69
                    defb      $6e                           ;[155d] 6e
                    defb      $69                           ;[155e] 69
                    defb      $74                           ;[155f] 74
                    defb      $20                           ;[1560] 20
                    defb      $66                           ;[1561] 66
                    defb      $61                           ;[1562] 61
                    defb      $69                           ;[1563] 69
                    defb      $6c                           ;[1564] 6c
                    defb      $65                           ;[1565] 65
                    defb      $64                           ;[1566] 64
                    defb      $0a                           ;[1567] 0a
                    defb      $00                           ;[1568] 00
___str_8_kernel_c:
                    defb      $4d                           ;[1569] 4d
                    defb      $65                           ;[156a] 65
                    defb      $6e                           ;[156b] 6e
                    defb      $69                           ;[156c] 69
                    defb      $20                           ;[156d] 20
                    defb      $76                           ;[156e] 76
                    defb      $69                           ;[156f] 69
                    defb      $74                           ;[1570] 74
                    defb      $75                           ;[1571] 75
                    defb      $69                           ;[1572] 69
                    defb      $6b                           ;[1573] 6b
                    defb      $73                           ;[1574] 73
                    defb      $00                           ;[1575] 00
___str_0_mfs_c:
                    defb      $20                           ;[1576] 20
                    defb      $52                           ;[1577] 52
                    defb      $6f                           ;[1578] 6f
                    defb      $6f                           ;[1579] 6f
                    defb      $74                           ;[157a] 74
                    defb      $20                           ;[157b] 20
                    defb      $46                           ;[157c] 46
                    defb      $53                           ;[157d] 53
                    defb      $20                           ;[157e] 20
                    defb      $63                           ;[157f] 63
                    defb      $68                           ;[1580] 68
                    defb      $65                           ;[1581] 65
                    defb      $63                           ;[1582] 63
                    defb      $6b                           ;[1583] 6b
                    defb      $73                           ;[1584] 73
                    defb      $75                           ;[1585] 75
                    defb      $6d                           ;[1586] 6d
                    defb      $20                           ;[1587] 20
                    defb      $69                           ;[1588] 69
                    defb      $6e                           ;[1589] 6e
                    defb      $63                           ;[158a] 63
                    defb      $6f                           ;[158b] 6f
                    defb      $72                           ;[158c] 72
                    defb      $72                           ;[158d] 72
                    defb      $65                           ;[158e] 65
                    defb      $63                           ;[158f] 63
                    defb      $74                           ;[1590] 74
                    defb      $2e                           ;[1591] 2e
                    defb      $20                           ;[1592] 20
                    defb      $53                           ;[1593] 53
                    defb      $6f                           ;[1594] 6f
                    defb      $6d                           ;[1595] 6d
                    defb      $65                           ;[1596] 65
                    defb      $20                           ;[1597] 20
                    defb      $66                           ;[1598] 66
                    defb      $69                           ;[1599] 69
                    defb      $6c                           ;[159a] 6c
                    defb      $65                           ;[159b] 65
                    defb      $73                           ;[159c] 73
                    defb      $20                           ;[159d] 20
                    defb      $6d                           ;[159e] 6d
                    defb      $61                           ;[159f] 61
                    defb      $79                           ;[15a0] 79
                    defb      $20                           ;[15a1] 20
                    defb      $62                           ;[15a2] 62
                    defb      $65                           ;[15a3] 65
                    defb      $20                           ;[15a4] 20
                    defb      $63                           ;[15a5] 63
                    defb      $6f                           ;[15a6] 6f
                    defb      $72                           ;[15a7] 72
                    defb      $72                           ;[15a8] 72
                    defb      $75                           ;[15a9] 75
                    defb      $70                           ;[15aa] 70
                    defb      $74                           ;[15ab] 74
                    defb      $65                           ;[15ac] 65
                    defb      $64                           ;[15ad] 64
                    defb      $0a                           ;[15ae] 0a
                    defb      $00                           ;[15af] 00
___str_1_mfs_c:
                    defb      $20                           ;[15b0] 20
                    defb      $52                           ;[15b1] 52
                    defb      $6f                           ;[15b2] 6f
                    defb      $6f                           ;[15b3] 6f
                    defb      $74                           ;[15b4] 74
                    defb      $20                           ;[15b5] 20
                    defb      $46                           ;[15b6] 46
                    defb      $53                           ;[15b7] 53
                    defb      $20                           ;[15b8] 20
                    defb      $6e                           ;[15b9] 6e
                    defb      $6f                           ;[15ba] 6f
                    defb      $74                           ;[15bb] 74
                    defb      $20                           ;[15bc] 20
                    defb      $66                           ;[15bd] 66
                    defb      $6f                           ;[15be] 6f
                    defb      $72                           ;[15bf] 72
                    defb      $6d                           ;[15c0] 6d
                    defb      $61                           ;[15c1] 61
                    defb      $74                           ;[15c2] 74
                    defb      $74                           ;[15c3] 74
                    defb      $65                           ;[15c4] 65
                    defb      $64                           ;[15c5] 64
                    defb      $20                           ;[15c6] 20
                    defb      $79                           ;[15c7] 79
                    defb      $65                           ;[15c8] 65
                    defb      $74                           ;[15c9] 74
                    defb      $2e                           ;[15ca] 2e
                    defb      $20                           ;[15cb] 20
                    defb      $46                           ;[15cc] 46
                    defb      $6f                           ;[15cd] 6f
                    defb      $72                           ;[15ce] 72
                    defb      $6d                           ;[15cf] 6d
                    defb      $61                           ;[15d0] 61
                    defb      $74                           ;[15d1] 74
                    defb      $3f                           ;[15d2] 3f
                    defb      $20                           ;[15d3] 20
                    defb      $28                           ;[15d4] 28
                    defb      $79                           ;[15d5] 79
                    defb      $2f                           ;[15d6] 2f
                    defb      $6e                           ;[15d7] 6e
                    defb      $29                           ;[15d8] 29
                    defb      $3a                           ;[15d9] 3a
                    defb      $20                           ;[15da] 20
                    defb      $00                           ;[15db] 00
___str_2_mfs_c:
                    defb      $20                           ;[15dc] 20
                    defb      $52                           ;[15dd] 52
                    defb      $6f                           ;[15de] 6f
                    defb      $6f                           ;[15df] 6f
                    defb      $74                           ;[15e0] 74
                    defb      $20                           ;[15e1] 20
                    defb      $46                           ;[15e2] 46
                    defb      $53                           ;[15e3] 53
                    defb      $20                           ;[15e4] 20
                    defb      $6c                           ;[15e5] 6c
                    defb      $6f                           ;[15e6] 6f
                    defb      $61                           ;[15e7] 61
                    defb      $64                           ;[15e8] 64
                    defb      $65                           ;[15e9] 65
                    defb      $64                           ;[15ea] 64
                    defb      $0a                           ;[15eb] 0a
                    defb      $00                           ;[15ec] 00
___str_3_mfs_c:
                    defb      $20                           ;[15ed] 20
                    defb      $4c                           ;[15ee] 4c
                    defb      $6f                           ;[15ef] 6f
                    defb      $61                           ;[15f0] 61
                    defb      $64                           ;[15f1] 64
                    defb      $69                           ;[15f2] 69
                    defb      $6e                           ;[15f3] 6e
                    defb      $67                           ;[15f4] 67
                    defb      $20                           ;[15f5] 20
                    defb      $52                           ;[15f6] 52
                    defb      $6f                           ;[15f7] 6f
                    defb      $6f                           ;[15f8] 6f
                    defb      $74                           ;[15f9] 74
                    defb      $20                           ;[15fa] 20
                    defb      $46                           ;[15fb] 46
                    defb      $53                           ;[15fc] 53
                    defb      $20                           ;[15fd] 20
                    defb      $66                           ;[15fe] 66
                    defb      $61                           ;[15ff] 61
                    defb      $69                           ;[1600] 69
                    defb      $6c                           ;[1601] 6c
                    defb      $65                           ;[1602] 65
                    defb      $64                           ;[1603] 64
                    defb      $0a                           ;[1604] 0a
                    defb      $00                           ;[1605] 00
___str_4_mfs_c:
                    defb      $46                           ;[1606] 46
                    defb      $69                           ;[1607] 69
                    defb      $6c                           ;[1608] 6c
                    defb      $65                           ;[1609] 65
                    defb      $3a                           ;[160a] 3a
                    defb      $20                           ;[160b] 20
                    defb      $00                           ;[160c] 00
___str_5_mfs_c:
                    defb      $53                           ;[160d] 53
                    defb      $69                           ;[160e] 69
                    defb      $7a                           ;[160f] 7a
                    defb      $65                           ;[1610] 65
                    defb      $3a                           ;[1611] 3a
                    defb      $20                           ;[1612] 20
                    defb      $00                           ;[1613] 00
___str_6_mfs_c:
                    defb      $42                           ;[1614] 42
                    defb      $6c                           ;[1615] 6c
                    defb      $6f                           ;[1616] 6f
                    defb      $63                           ;[1617] 63
                    defb      $6b                           ;[1618] 6b
                    defb      $20                           ;[1619] 20
                    defb      $73                           ;[161a] 73
                    defb      $69                           ;[161b] 69
                    defb      $7a                           ;[161c] 7a
                    defb      $65                           ;[161d] 65
                    defb      $3a                           ;[161e] 3a
                    defb      $20                           ;[161f] 20
                    defb      $00                           ;[1620] 00
___str_7_mfs_c:
                    defb      $46                           ;[1621] 46
                    defb      $69                           ;[1622] 69
                    defb      $72                           ;[1623] 72
                    defb      $73                           ;[1624] 73
                    defb      $74                           ;[1625] 74
                    defb      $20                           ;[1626] 20
                    defb      $42                           ;[1627] 42
                    defb      $6c                           ;[1628] 6c
                    defb      $6f                           ;[1629] 6f
                    defb      $63                           ;[162a] 63
                    defb      $6b                           ;[162b] 6b
                    defb      $3a                           ;[162c] 3a
                    defb      $20                           ;[162d] 20
                    defb      $00                           ;[162e] 00
___str_8_mfs_c:
                    defb      $0a                           ;[162f] 0a
                    defb      $46                           ;[1630] 46
                    defb      $69                           ;[1631] 69
                    defb      $6c                           ;[1632] 6c
                    defb      $65                           ;[1633] 65
                    defb      $20                           ;[1634] 20
                    defb      $6c                           ;[1635] 6c
                    defb      $69                           ;[1636] 69
                    defb      $73                           ;[1637] 73
                    defb      $74                           ;[1638] 74
                    defb      $3a                           ;[1639] 3a
                    defb      $00                           ;[163a] 00
___str_9:
                    defb      $46                           ;[163b] 46
                    defb      $69                           ;[163c] 69
                    defb      $6c                           ;[163d] 6c
                    defb      $65                           ;[163e] 65
                    defb      $73                           ;[163f] 73
                    defb      $79                           ;[1640] 79
                    defb      $73                           ;[1641] 73
                    defb      $74                           ;[1642] 74
                    defb      $65                           ;[1643] 65
                    defb      $6d                           ;[1644] 6d
                    defb      $20                           ;[1645] 20
                    defb      $64                           ;[1646] 64
                    defb      $65                           ;[1647] 65
                    defb      $62                           ;[1648] 62
                    defb      $75                           ;[1649] 75
                    defb      $67                           ;[164a] 67
                    defb      $20                           ;[164b] 20
                    defb      $69                           ;[164c] 69
                    defb      $6e                           ;[164d] 6e
                    defb      $66                           ;[164e] 66
                    defb      $6f                           ;[164f] 6f
                    defb      $3a                           ;[1650] 3a
                    defb      $0a                           ;[1651] 0a
                    defb      $00                           ;[1652] 00
___str_10:
                    defb      $43                           ;[1653] 43
                    defb      $68                           ;[1654] 68
                    defb      $65                           ;[1655] 65
                    defb      $63                           ;[1656] 63
                    defb      $6b                           ;[1657] 6b
                    defb      $73                           ;[1658] 73
                    defb      $75                           ;[1659] 75
                    defb      $6d                           ;[165a] 6d
                    defb      $3a                           ;[165b] 3a
                    defb      $20                           ;[165c] 20
                    defb      $00                           ;[165d] 00
___str_11:
                    defb      $0a                           ;[165e] 0a
                    defb      $00                           ;[165f] 00
___str_12:
                    defb      $46                           ;[1660] 46
                    defb      $6f                           ;[1661] 6f
                    defb      $72                           ;[1662] 72
                    defb      $6d                           ;[1663] 6d
                    defb      $61                           ;[1664] 61
                    defb      $74                           ;[1665] 74
                    defb      $74                           ;[1666] 74
                    defb      $65                           ;[1667] 65
                    defb      $64                           ;[1668] 64
                    defb      $3a                           ;[1669] 3a
                    defb      $20                           ;[166a] 20
                    defb      $00                           ;[166b] 00
___str_13:
                    defb      $46                           ;[166c] 46
                    defb      $69                           ;[166d] 69
                    defb      $6c                           ;[166e] 6c
                    defb      $65                           ;[166f] 65
                    defb      $63                           ;[1670] 63
                    defb      $6f                           ;[1671] 6f
                    defb      $75                           ;[1672] 75
                    defb      $6e                           ;[1673] 6e
                    defb      $74                           ;[1674] 74
                    defb      $3a                           ;[1675] 3a
                    defb      $20                           ;[1676] 20
                    defb      $00                           ;[1677] 00
___str_14:
                    defb      $46                           ;[1678] 46
                    defb      $69                           ;[1679] 69
                    defb      $6c                           ;[167a] 6c
                    defb      $65                           ;[167b] 65
                    defb      $74                           ;[167c] 74
                    defb      $61                           ;[167d] 61
                    defb      $62                           ;[167e] 62
                    defb      $6c                           ;[167f] 6c
                    defb      $65                           ;[1680] 65
                    defb      $3a                           ;[1681] 3a
                    defb      $20                           ;[1682] 20
                    defb      $00                           ;[1683] 00
SYSINFO_kmain:
                    defb      $4d                           ;[1684] 4d
                    defb      $61                           ;[1685] 61
                    defb      $6e                           ;[1686] 6e
                    defb      $75                           ;[1687] 75
                    defb      $78                           ;[1688] 78
                    defb      $20                           ;[1689] 20
                    defb      $20                           ;[168a] 20
                    defb      $20                           ;[168b] 20
                    defb      $00                           ;[168c] 00
                    defb      $5a                           ;[168d] 5a
                    defb      $38                           ;[168e] 38
                    defb      $30                           ;[168f] 30
                    defb      $2d                           ;[1690] 2d
                    defb      $50                           ;[1691] 50
                    defb      $43                           ;[1692] 43
                    defb      $20                           ;[1693] 20
                    defb      $20                           ;[1694] 20
                    defb      $00                           ;[1695] 00
                    defb      $30                           ;[1696] 30
                    defb      $2e                           ;[1697] 2e
                    defb      $33                           ;[1698] 33
                    defb      $2e                           ;[1699] 2e
                    defb      $30                           ;[169a] 30
                    defb      $20                           ;[169b] 20
                    defb      $20                           ;[169c] 20
                    defb      $20                           ;[169d] 20
                    defb      $00                           ;[169e] 00
                    defb      $70                           ;[169f] 70
                    defb      $72                           ;[16a0] 72
                    defb      $65                           ;[16a1] 65
                    defb      $6c                           ;[16a2] 6c
                    defb      $65                           ;[16a3] 65
                    defb      $61                           ;[16a4] 61
                    defb      $73                           ;[16a5] 73
                    defb      $65                           ;[16a6] 65
                    defb      $00                           ;[16a7] 00
                    defb      $5a                           ;[16a8] 5a
                    defb      $38                           ;[16a9] 38
                    defb      $30                           ;[16aa] 30
                    defb      $20                           ;[16ab] 20
                    defb      $20                           ;[16ac] 20
                    defb      $20                           ;[16ad] 20
                    defb      $20                           ;[16ae] 20
                    defb      $20                           ;[16af] 20
                    defb      $00                           ;[16b0] 00
MSG_kmain:
                    defb      $48                           ;[16b1] 48
                    defb      $65                           ;[16b2] 65
                    defb      $6c                           ;[16b3] 6c
                    defb      $6c                           ;[16b4] 6c
                    defb      $6f                           ;[16b5] 6f
                    defb      $72                           ;[16b6] 72
                    defb      $64                           ;[16b7] 64
                    defb      $0d                           ;[16b8] 0d
                    defb      $0a                           ;[16b9] 0a
                    defb      $00                           ;[16ba] 00
KP_MSG_kmain:
                    defb      $4b                           ;[16bb] 4b
                    defb      $65                           ;[16bc] 65
                    defb      $72                           ;[16bd] 72
                    defb      $6e                           ;[16be] 6e
                    defb      $65                           ;[16bf] 65
                    defb      $6c                           ;[16c0] 6c
                    defb      $20                           ;[16c1] 20
                    defb      $50                           ;[16c2] 50
                    defb      $61                           ;[16c3] 61
                    defb      $6e                           ;[16c4] 6e
                    defb      $69                           ;[16c5] 69
                    defb      $63                           ;[16c6] 63
                    defb      $21                           ;[16c7] 21
                    defb      $00                           ;[16c8] 00
STACKTRACE_MSG:
                    defb      $53                           ;[16c9] 53
                    defb      $74                           ;[16ca] 74
                    defb      $61                           ;[16cb] 61
                    defb      $63                           ;[16cc] 63
                    defb      $6b                           ;[16cd] 6b
                    defb      $74                           ;[16ce] 74
                    defb      $72                           ;[16cf] 72
                    defb      $61                           ;[16d0] 61
                    defb      $63                           ;[16d1] 63
                    defb      $65                           ;[16d2] 65
                    defb      $3a                           ;[16d3] 3a
                    defb      $20                           ;[16d4] 20
                    defb      $00                           ;[16d5] 00
REG_AF:
                    defb      $20                           ;[16d6] 20
                    defb      $41                           ;[16d7] 41
                    defb      $46                           ;[16d8] 46
                    defb      $3a                           ;[16d9] 3a
                    defb      $20                           ;[16da] 20
                    defb      $00                           ;[16db] 00
REG_BC:
                    defb      $20                           ;[16dc] 20
                    defb      $42                           ;[16dd] 42
                    defb      $43                           ;[16de] 43
                    defb      $3a                           ;[16df] 3a
                    defb      $20                           ;[16e0] 20
                    defb      $00                           ;[16e1] 00
REG_DE:
                    defb      $20                           ;[16e2] 20
                    defb      $44                           ;[16e3] 44
                    defb      $45                           ;[16e4] 45
                    defb      $3a                           ;[16e5] 3a
                    defb      $20                           ;[16e6] 20
                    defb      $00                           ;[16e7] 00
REG_HL:
                    defb      $20                           ;[16e8] 20
                    defb      $48                           ;[16e9] 48
                    defb      $4c                           ;[16ea] 4c
                    defb      $3a                           ;[16eb] 3a
                    defb      $20                           ;[16ec] 20
                    defb      $00                           ;[16ed] 00
REG_IX:
                    defb      $20                           ;[16ee] 20
                    defb      $49                           ;[16ef] 49
                    defb      $58                           ;[16f0] 58
                    defb      $3a                           ;[16f1] 3a
                    defb      $20                           ;[16f2] 20
                    defb      $00                           ;[16f3] 00
REG_IY:
                    defb      $20                           ;[16f4] 20
                    defb      $49                           ;[16f5] 49
                    defb      $59                           ;[16f6] 59
                    defb      $3a                           ;[16f7] 3a
                    defb      $20                           ;[16f8] 20
                    defb      $00                           ;[16f9] 00
REG_SP:
                    defb      $20                           ;[16fa] 20
                    defb      $53                           ;[16fb] 53
                    defb      $50                           ;[16fc] 50
                    defb      $3a                           ;[16fd] 3a
                    defb      $20                           ;[16fe] 20
                    defb      $00                           ;[16ff] 00
SYSINFO_system_call:
                    defb      $4d                           ;[1700] 4d
                    defb      $61                           ;[1701] 61
                    defb      $6e                           ;[1702] 6e
                    defb      $75                           ;[1703] 75
                    defb      $78                           ;[1704] 78
                    defb      $20                           ;[1705] 20
                    defb      $20                           ;[1706] 20
                    defb      $20                           ;[1707] 20
                    defb      $00                           ;[1708] 00
                    defb      $5a                           ;[1709] 5a
                    defb      $38                           ;[170a] 38
                    defb      $30                           ;[170b] 30
                    defb      $2d                           ;[170c] 2d
                    defb      $50                           ;[170d] 50
                    defb      $43                           ;[170e] 43
                    defb      $20                           ;[170f] 20
                    defb      $20                           ;[1710] 20
                    defb      $00                           ;[1711] 00
                    defb      $30                           ;[1712] 30
                    defb      $2e                           ;[1713] 2e
                    defb      $33                           ;[1714] 33
                    defb      $2e                           ;[1715] 2e
                    defb      $30                           ;[1716] 30
                    defb      $20                           ;[1717] 20
                    defb      $20                           ;[1718] 20
                    defb      $20                           ;[1719] 20
                    defb      $00                           ;[171a] 00
                    defb      $70                           ;[171b] 70
                    defb      $72                           ;[171c] 72
                    defb      $65                           ;[171d] 65
                    defb      $6c                           ;[171e] 6c
                    defb      $65                           ;[171f] 65
                    defb      $61                           ;[1720] 61
                    defb      $73                           ;[1721] 73
                    defb      $65                           ;[1722] 65
                    defb      $00                           ;[1723] 00
                    defb      $5a                           ;[1724] 5a
                    defb      $38                           ;[1725] 38
                    defb      $30                           ;[1726] 30
                    defb      $20                           ;[1727] 20
                    defb      $20                           ;[1728] 20
                    defb      $20                           ;[1729] 20
                    defb      $20                           ;[172a] 20
                    defb      $20                           ;[172b] 20
                    defb      $00                           ;[172c] 00
MSG_system_call:
                    defb      $48                           ;[172d] 48
                    defb      $65                           ;[172e] 65
                    defb      $6c                           ;[172f] 6c
                    defb      $6c                           ;[1730] 6c
                    defb      $6f                           ;[1731] 6f
                    defb      $72                           ;[1732] 72
                    defb      $64                           ;[1733] 64
                    defb      $0d                           ;[1734] 0d
                    defb      $0a                           ;[1735] 0a
                    defb      $00                           ;[1736] 00
KP_MSG_system_call:
                    defb      $4b                           ;[1737] 4b
                    defb      $65                           ;[1738] 65
                    defb      $72                           ;[1739] 72
                    defb      $6e                           ;[173a] 6e
                    defb      $65                           ;[173b] 65
                    defb      $6c                           ;[173c] 6c
                    defb      $20                           ;[173d] 20
                    defb      $50                           ;[173e] 50
                    defb      $61                           ;[173f] 61
                    defb      $6e                           ;[1740] 6e
                    defb      $69                           ;[1741] 69
                    defb      $63                           ;[1742] 63
                    defb      $21                           ;[1743] 21
                    defb      $00                           ;[1744] 00
__malloc_heap:
                    defb      $c0                           ;[1745] c0
                    defb      $2a                           ;[1746] 2a
__stdio_heap:
                    defb      $02                           ;[1747] 02
                    defb      $2a                           ;[1748] 2a
__stdio_closed_file_list:
                    defb      $00                           ;[1749] 00
                    defb      $00                           ;[174a] 00
                    defb      $49                           ;[174b] 49
                    defb      $17                           ;[174c] 17
__thrd_id:
                    defb      $01                           ;[174d] 01
_pih:
                    defb      $00                           ;[174e] 00
                    defb      $40                           ;[174f] 40
_checksum:
                    defb      $00                           ;[1750] 00
                    defb      $f2                           ;[1751] f2
_formatted:
                    defb      $02                           ;[1752] 02
                    defb      $f2                           ;[1753] f2
_filecount:
                    defb      $03                           ;[1754] 03
                    defb      $f2                           ;[1755] f2
_files:
                    defb      $04                           ;[1756] 04
                    defb      $f2                           ;[1757] f2
_fs_rootfs:
                    defb      $00                           ;[1758] 00
                    defb      $f2                           ;[1759] f2
_tempbuf:
                    defb      $00                           ;[175a] 00
                    defb      $f0                           ;[175b] f0
