start:
                    call      crt0_init                     ;[a004] cd 17 a0
                    call      KERNEL_ENTRY                  ;[a007] cd b1 a0
__Exit:
                    ret                                     ;[a00a] c9

_fputc_cons:
                    call      TRANSMIT_CHAR                 ;[a00b] cd 31 a0
                    ret                                     ;[a00e] c9

_fgetc_cons:
                    call      RECEIVE_CHAR                  ;[a00f] cd 33 a0
                    ld        l,a                           ;[a012] 6f
                    ld        h,$00                         ;[a013] 26 00
                    ret                                     ;[a015] c9

l_dcal:
                    jp        (hl)                          ;[a016] e9
crt0_init:
                    ld        hl,$d003                      ;[a017] 21 03 d0
                    ld        (hl),$12                      ;[a01a] 36 12
                    ld        hl,$d00d                      ;[a01c] 21 0d d0
                    ld        (hl),$14                      ;[a01f] 36 14
                    ld        hl,$d017                      ;[a021] 21 17 d0
                    ld        (hl),$14                      ;[a024] 36 14
                    ld        hl,$b1d7                      ;[a026] 21 d7 b1
                    ld        de,$d0df                      ;[a029] 11 df d0
                    call      asm_dzx7_standard             ;[a02c] cd b6 b0
                    ret                                     ;[a02f] c9

crt0_exit:
                    ret                                     ;[a030] c9

TRANSMIT_CHAR:
                    rst       $08                           ;[a031] cf
                    ret                                     ;[a032] c9

RECEIVE_CHAR:
                    rst       $10                           ;[a033] d7
                    ret                                     ;[a034] c9

INIT_TTY:
                    ret                                     ;[a035] c9

l_asr_u:
                    ex        de,hl                         ;[a036] eb
l_asr_u_hl_by_e:
                    dec       e                             ;[a037] 1d
                    ret       m                             ;[a038] f8
                    srl       h                             ;[a039] cb 3c
                    rr        l                             ;[a03b] cb 1d
                    jp        l_asr_u_hl_by_e               ;[a03d] c3 37 a0
l_eq:
                    or        a                             ;[a040] b7
                    sbc       hl,de                         ;[a041] ed 52
                    scf                                     ;[a043] 37
                    inc       hl                            ;[a044] 23
                    ret       z                             ;[a045] c8
                    xor       a                             ;[a046] af
                    ld        l,a                           ;[a047] 6f
                    ld        h,a                           ;[a048] 67
                    ret                                     ;[a049] c9

l_g2intspsp:
                    add       hl,sp                         ;[a04a] 39
                    ld        b,h                           ;[a04b] 44
                    ld        c,l                           ;[a04c] 4d
                    inc       hl                            ;[a04d] 23
                    inc       hl                            ;[a04e] 23
                    ld        a,(hl)                        ;[a04f] 7e
                    inc       hl                            ;[a050] 23
                    ld        h,(hl)                        ;[a051] 66
                    ld        l,a                           ;[a052] 6f
                    ex        (sp),hl                       ;[a053] e3
                    push      hl                            ;[a054] e5
                    ld        h,b                           ;[a055] 60
                    ld        l,c                           ;[a056] 69
                    ld        a,(hl)                        ;[a057] 7e
                    inc       hl                            ;[a058] 23
                    ld        h,(hl)                        ;[a059] 66
                    ld        l,a                           ;[a05a] 6f
                    ex        (sp),hl                       ;[a05b] e3
                    jp        (hl)                          ;[a05c] e9
l_gintspsp:
                    add       hl,sp                         ;[a05d] 39
                    inc       hl                            ;[a05e] 23
                    inc       hl                            ;[a05f] 23
                    ld        a,(hl)                        ;[a060] 7e
                    inc       hl                            ;[a061] 23
                    ld        h,(hl)                        ;[a062] 66
                    ld        l,a                           ;[a063] 6f
                    ex        (sp),hl                       ;[a064] e3
                    jp        (hl)                          ;[a065] e9
l_gint3:
                    inc       hl                            ;[a066] 23
l_gint2:
                    inc       hl                            ;[a067] 23
l_gint1:
                    inc       hl                            ;[a068] 23
l_gint:
                    ld        a,(hl)                        ;[a069] 7e
                    inc       hl                            ;[a06a] 23
                    ld        h,(hl)                        ;[a06b] 66
                    ld        l,a                           ;[a06c] 6f
                    ret                                     ;[a06d] c9

l_gint1sp:
                    ld        hl,$0003                      ;[a06e] 21 03 00
                    add       hl,sp                         ;[a071] 39
                    ld        a,(hl)                        ;[a072] 7e
                    inc       hl                            ;[a073] 23
                    ld        h,(hl)                        ;[a074] 66
                    ld        l,a                           ;[a075] 6f
                    ret                                     ;[a076] c9

l_gint4sp:
                    ld        hl,$0006                      ;[a077] 21 06 00
                    add       hl,sp                         ;[a07a] 39
                    ld        a,(hl)                        ;[a07b] 7e
                    inc       hl                            ;[a07c] 23
                    ld        h,(hl)                        ;[a07d] 66
                    ld        l,a                           ;[a07e] 6f
                    ret                                     ;[a07f] c9

l_gint6sp:
                    ld        hl,$0008                      ;[a080] 21 08 00
                    add       hl,sp                         ;[a083] 39
                    ld        a,(hl)                        ;[a084] 7e
                    inc       hl                            ;[a085] 23
                    ld        h,(hl)                        ;[a086] 66
                    ld        l,a                           ;[a087] 6f
                    ret                                     ;[a088] c9

l_gint8sp:
                    ld        hl,$000a                      ;[a089] 21 0a 00
                    add       hl,sp                         ;[a08c] 39
                    ld        a,(hl)                        ;[a08d] 7e
                    inc       hl                            ;[a08e] 23
                    ld        h,(hl)                        ;[a08f] 66
                    ld        l,a                           ;[a090] 6f
                    ret                                     ;[a091] c9

l_pint_pop:
                    pop       bc                            ;[a092] c1
                    pop       de                            ;[a093] d1
                    push      bc                            ;[a094] c5
l_pint:
                    ld        a,l                           ;[a095] 7d
                    ld        (de),a                        ;[a096] 12
                    inc       de                            ;[a097] 13
                    ld        a,h                           ;[a098] 7c
                    ld        (de),a                        ;[a099] 12
                    ret                                     ;[a09a] c9

                    pop       hl                            ;[a09b] e1
                    pop       hl                            ;[a09c] e1
                    pop       hl                            ;[a09d] e1
l_ret:
                    ret                                     ;[a09e] c9

l_uge:
                    ld        a,d                           ;[a09f] 7a
                    cp        h                             ;[a0a0] bc
                    ccf                                     ;[a0a1] 3f
                    jp        nz,l_compare_result           ;[a0a2] c2 ab a0
                    ld        a,e                           ;[a0a5] 7b
                    cp        l                             ;[a0a6] bd
                    ccf                                     ;[a0a7] 3f
                    jp        l_compare_result              ;[a0a8] c3 ab a0
l_compare_result:
                    ld        hl,$0000                      ;[a0ab] 21 00 00
                    ret       nc                            ;[a0ae] d0
                    inc       hl                            ;[a0af] 23
                    ret                                     ;[a0b0] c9

KERNEL_ENTRY:
                    ld        hl,$0000                      ;[a0b1] 21 00 00
                    add       hl,sp                         ;[a0b4] 39
                    ld        sp,$ce00                      ;[a0b5] 31 00 ce
                    push      hl                            ;[a0b8] e5
                    ld        ($9002),sp                    ;[a0b9] ed 73 02 90
                    call      INIT_TTY                      ;[a0bd] cd 35 a0
                    ld        hl,$a000                      ;[a0c0] 21 00 a0
                    ld        de,$a1fc                      ;[a0c3] 11 fc a1
                    ld        (hl),$c3                      ;[a0c6] 36 c3
                    inc       hl                            ;[a0c8] 23
                    ld        (hl),e                        ;[a0c9] 73
                    inc       hl                            ;[a0ca] 23
                    ld        (hl),d                        ;[a0cb] 72
                    ld        a,$10                         ;[a0cc] 3e 10
                    ld        ($9008),a                     ;[a0ce] 32 08 90
                    xor       a                             ;[a0d1] af
                    ld        hl,$900a                      ;[a0d2] 21 0a 90
                    ld        (hl),a                        ;[a0d5] 77
                    set       0,(hl)                        ;[a0d6] cb c6
                    ld        hl,$900c                      ;[a0d8] 21 0c 90
                    ld        (hl),a                        ;[a0db] 77
                    ld        hl,$cf01                      ;[a0dc] 21 01 cf
                    ld        ($9006),hl                    ;[a0df] 22 06 90
                    ld        hl,$cd00                      ;[a0e2] 21 00 cd
                    ld        ($9004),hl                    ;[a0e5] 22 04 90
                    ld        sp,($9004)                    ;[a0e8] ed 7b 04 90
                    ld        a,$09                         ;[a0ec] 3e 09
                    call      $a000                         ;[a0ee] cd 00 a0
                    ld        hl,$a35e                      ;[a0f1] 21 5e a3
                    ld        a,$05                         ;[a0f4] 3e 05
                    call      $a000                         ;[a0f6] cd 00 a0
                    ld        ($9004),sp                    ;[a0f9] ed 73 04 90
                    ld        sp,($9002)                    ;[a0fd] ed 7b 02 90
                    pop       hl                            ;[a101] e1
                    ld        sp,hl                         ;[a102] f9
                    ret                                     ;[a103] c9

MINIMAL_PUTS:
                    ld        a,(hl)                        ;[a104] 7e
                    or        a                             ;[a105] b7
                    ret       z                             ;[a106] c8
                    call      TRANSMIT_CHAR                 ;[a107] cd 31 a0
                    inc       hl                            ;[a10a] 23
                    jp        MINIMAL_PUTS                  ;[a10b] c3 04 a1
REG_DUMP:
                    push      af                            ;[a10e] f5
                    push      bc                            ;[a10f] c5
                    push      de                            ;[a110] d5
                    push      hl                            ;[a111] e5
                    push      ix                            ;[a112] dd e5
                    push      iy                            ;[a114] fd e5
                    push      iy                            ;[a116] fd e5
                    push      ix                            ;[a118] dd e5
                    push      hl                            ;[a11a] e5
                    push      de                            ;[a11b] d5
                    push      bc                            ;[a11c] c5
                    push      af                            ;[a11d] f5
                    ld        hl,$d1ec                      ;[a11e] 21 ec d1
                    call      MINIMAL_PUTS                  ;[a121] cd 04 a1
                    pop       hl                            ;[a124] e1
                    call      _puth                         ;[a125] cd 49 a9
                    ld        hl,$d1f2                      ;[a128] 21 f2 d1
                    call      MINIMAL_PUTS                  ;[a12b] cd 04 a1
                    pop       hl                            ;[a12e] e1
                    call      _puth                         ;[a12f] cd 49 a9
                    ld        hl,$d1f8                      ;[a132] 21 f8 d1
                    call      MINIMAL_PUTS                  ;[a135] cd 04 a1
                    pop       hl                            ;[a138] e1
                    call      _puth                         ;[a139] cd 49 a9
                    ld        hl,$d1fe                      ;[a13c] 21 fe d1
                    call      MINIMAL_PUTS                  ;[a13f] cd 04 a1
                    pop       hl                            ;[a142] e1
                    call      _puth                         ;[a143] cd 49 a9
                    ld        hl,$d204                      ;[a146] 21 04 d2
                    call      MINIMAL_PUTS                  ;[a149] cd 04 a1
                    pop       hl                            ;[a14c] e1
                    call      _puth                         ;[a14d] cd 49 a9
                    ld        hl,$d20a                      ;[a150] 21 0a d2
                    call      MINIMAL_PUTS                  ;[a153] cd 04 a1
                    pop       hl                            ;[a156] e1
                    call      _puth                         ;[a157] cd 49 a9
                    ld        hl,$d210                      ;[a15a] 21 10 d2
                    call      MINIMAL_PUTS                  ;[a15d] cd 04 a1
                    ld        hl,$0000                      ;[a160] 21 00 00
                    add       hl,sp                         ;[a163] 39
                    call      _puth                         ;[a164] cd 49 a9
                    pop       iy                            ;[a167] fd e1
                    pop       ix                            ;[a169] dd e1
                    pop       hl                            ;[a16b] e1
                    pop       de                            ;[a16c] d1
                    pop       bc                            ;[a16d] c1
                    pop       af                            ;[a16e] f1
                    ret                                     ;[a16f] c9

STACKTRACE:
                    push      bc                            ;[a170] c5
                    push      hl                            ;[a171] e5
                    ld        hl,$d1df                      ;[a172] 21 df d1
                    call      MINIMAL_PUTS                  ;[a175] cd 04 a1
                    ld        hl,$0000                      ;[a178] 21 00 00
                    add       hl,sp                         ;[a17b] 39
ST_LOOP:
                    ld        e,(hl)                        ;[a17c] 5e
                    inc       hl                            ;[a17d] 23
                    ld        d,(hl)                        ;[a17e] 56
                    inc       hl                            ;[a17f] 23
                    ex        de,hl                         ;[a180] eb
                    push      bc                            ;[a181] c5
                    push      hl                            ;[a182] e5
                    call      _puth                         ;[a183] cd 49 a9
                    ex        de,hl                         ;[a186] eb
                    ld        a,$20                         ;[a187] 3e 20
                    call      TRANSMIT_CHAR                 ;[a189] cd 31 a0
                    pop       hl                            ;[a18c] e1
                    pop       bc                            ;[a18d] c1
                    dec       c                             ;[a18e] 0d
                    jr        nz,ST_LOOP                    ;[a18f] 20 eb
                    pop       hl                            ;[a191] e1
                    pop       bc                            ;[a192] c1
                    ret                                     ;[a193] c9

CREATE_PROCESS:
                    push      hl                            ;[a194] e5
                    push      af                            ;[a195] f5
                    ld        hl,$900c                      ;[a196] 21 0c 90
                    ld        a,$08                         ;[a199] 3e 08
                    cp        (hl)                          ;[a19b] be
                    jr        z,CREATE_PROCESS_END          ;[a19c] 28 01
                    inc       (hl)                          ;[a19e] 34
CREATE_PROCESS_END:
                    pop       af                            ;[a19f] f1
                    pop       hl                            ;[a1a0] e1
                    call      nz,PUSH_PROCESS               ;[a1a1] c4 b8 a1
                    ret                                     ;[a1a4] c9

EXIT_PROCESS:
                    ld        hl,$900c                      ;[a1a5] 21 0c 90
                    or        a                             ;[a1a8] b7
                    cp        (hl)                          ;[a1a9] be
                    ret       z                             ;[a1aa] c8
                    dec       (hl)                          ;[a1ab] 35
                    call      POP_PROCESS                   ;[a1ac] cd e1 a1
                    ret                                     ;[a1af] c9

GET_PROCESS_ID:
                    push      hl                            ;[a1b0] e5
                    ld        hl,($9006)                    ;[a1b1] 2a 06 90
                    inc       hl                            ;[a1b4] 23
                    ld        a,(hl)                        ;[a1b5] 7e
                    pop       hl                            ;[a1b6] e1
                    ret                                     ;[a1b7] c9

PUSH_PROCESS:
                    ld        ($9010),hl                    ;[a1b8] 22 10 90
                    ld        ($9012),sp                    ;[a1bb] ed 73 12 90
                    ld        sp,($9006)                    ;[a1bf] ed 7b 06 90
                    ld        hl,($9010)                    ;[a1c3] 2a 10 90
                    push      af                            ;[a1c6] f5
                    push      bc                            ;[a1c7] c5
                    push      de                            ;[a1c8] d5
                    push      hl                            ;[a1c9] e5
                    ld        hl,($9004)                    ;[a1ca] 2a 04 90
                    push      hl                            ;[a1cd] e5
                    ld        e,(hl)                        ;[a1ce] 5e
                    inc       hl                            ;[a1cf] 23
                    ld        d,(hl)                        ;[a1d0] 56
                    push      de                            ;[a1d1] d5
                    ld        a,r                           ;[a1d2] ed 5f
                    ld        b,a                           ;[a1d4] 47
                    ld        c,$00                         ;[a1d5] 0e 00
                    push      bc                            ;[a1d7] c5
                    ld        ($9006),sp                    ;[a1d8] ed 73 06 90
                    ld        sp,($9012)                    ;[a1dc] ed 7b 12 90
                    ret                                     ;[a1e0] c9

POP_PROCESS:
                    ld        ($9010),sp                    ;[a1e1] ed 73 10 90
                    ld        sp,($9006)                    ;[a1e5] ed 7b 06 90
                    pop       hl                            ;[a1e9] e1
                    pop       hl                            ;[a1ea] e1
                    pop       hl                            ;[a1eb] e1
                    ld        ($9004),hl                    ;[a1ec] 22 04 90
                    pop       hl                            ;[a1ef] e1
                    pop       de                            ;[a1f0] d1
                    pop       bc                            ;[a1f1] c1
                    pop       af                            ;[a1f2] f1
                    ld        ($9006),sp                    ;[a1f3] ed 73 06 90
                    ld        sp,($9010)                    ;[a1f7] ed 7b 10 90
                    ret                                     ;[a1fb] c9

SYSCALL_DISPATCH:
                    ld        ($9004),sp                    ;[a1fc] ed 73 04 90
                    ld        sp,($9002)                    ;[a200] ed 7b 02 90
                    push      hl                            ;[a204] e5
                    ld        hl,$9008                      ;[a205] 21 08 90
                    cp        (hl)                          ;[a208] be
                    pop       hl                            ;[a209] e1
                    jp        nc,SYSCALL_END                ;[a20a] d2 2f a2
                    push      af                            ;[a20d] f5
                    push      bc                            ;[a20e] c5
                    push      de                            ;[a20f] d5
                    push      hl                            ;[a210] e5
                    ld        ($9010),hl                    ;[a211] 22 10 90
                    push      de                            ;[a214] d5
                    ld        hl,$d176                      ;[a215] 21 76 d1
                    sla       a                             ;[a218] cb 27
                    ld        d,$00                         ;[a21a] 16 00
                    ld        e,a                           ;[a21c] 5f
                    add       hl,de                         ;[a21d] 19
                    ld        e,(hl)                        ;[a21e] 5e
                    inc       hl                            ;[a21f] 23
                    ld        d,(hl)                        ;[a220] 56
                    ld        hl,$0000                      ;[a221] 21 00 00
                    add       hl,de                         ;[a224] 19
                    pop       de                            ;[a225] d1
                    jp        (hl)                          ;[a226] e9
GET_HL_SYSCALL:
                    ld        hl,($9010)                    ;[a227] 2a 10 90
                    ret                                     ;[a22a] c9

SAVE_RET:
                    ld        ($9012),hl                    ;[a22b] 22 12 90
                    ret                                     ;[a22e] c9

SYSCALL_END:
                    pop       hl                            ;[a22f] e1
                    pop       de                            ;[a230] d1
                    pop       bc                            ;[a231] c1
                    pop       af                            ;[a232] f1
                    ld        hl,($9012)                    ;[a233] 2a 12 90
SYSCALL_END_SKIP:
                    ld        sp,($9004)                    ;[a236] ed 7b 04 90
                    ret                                     ;[a23a] c9

ECHO_CHAR:
                    push      hl                            ;[a23b] e5
                    ld        hl,$900a                      ;[a23c] 21 0a 90
                    bit       0,(hl)                        ;[a23f] cb 46
                    pop       hl                            ;[a241] e1
                    call      nz,TRANSMIT_CHAR              ;[a242] c4 31 a0
                    ret                                     ;[a245] c9

SYS_EXIT:
                    call      GET_HL_SYSCALL                ;[a246] cd 27 a2
                    ld        ($900e),hl                    ;[a249] 22 0e 90
                    call      EXIT_PROCESS                  ;[a24c] cd a5 a1
                    jp        SYSCALL_END_SKIP              ;[a24f] c3 36 a2
SYS_WRITE:
                    call      GET_HL_SYSCALL                ;[a252] cd 27 a2
                    push      bc                            ;[a255] c5
                    push      de                            ;[a256] d5
                    push      hl                            ;[a257] e5
                    call      _sysc_write                   ;[a258] cd fc a3
                    pop       hl                            ;[a25b] e1
                    pop       de                            ;[a25c] d1
                    pop       bc                            ;[a25d] c1
SYS_WRITE_END:
                    jp        SYSCALL_END                   ;[a25e] c3 2f a2
SYS_READ:
                    call      GET_HL_SYSCALL                ;[a261] cd 27 a2
                    push      bc                            ;[a264] c5
                    push      de                            ;[a265] d5
                    push      hl                            ;[a266] e5
                    call      _sysc_read                    ;[a267] cd 80 a4
                    pop       hl                            ;[a26a] e1
                    pop       de                            ;[a26b] d1
                    pop       bc                            ;[a26c] c1
SYS_READ_END:
                    jp        SYSCALL_END                   ;[a26d] c3 2f a2
SYS_GETS:
                    call      GET_HL_SYSCALL                ;[a270] cd 27 a2
SYS_GETS_LOOP:
                    call      RECEIVE_CHAR                  ;[a273] cd 33 a0
                    call      ECHO_CHAR                     ;[a276] cd 3b a2
                    cp        $0d                           ;[a279] fe 0d
                    jr        z,SYS_GETS_END                ;[a27b] 28 1c
                    cp        $0a                           ;[a27d] fe 0a
                    jr        z,SYS_GETS_END                ;[a27f] 28 18
                    ld        (hl),a                        ;[a281] 77
                    inc       hl                            ;[a282] 23
                    cp        $7f                           ;[a283] fe 7f
                    jr        z,SYS_GETS_BCKSP              ;[a285] 28 0b
                    cp        $08                           ;[a287] fe 08
                    jr        z,SYS_GETS_BCKSP              ;[a289] 28 07
                    xor       a                             ;[a28b] af
                    dec       de                            ;[a28c] 1b
                    cp        e                             ;[a28d] bb
                    jr        z,SYS_GETS_END                ;[a28e] 28 09
                    jr        SYS_GETS_LOOP                 ;[a290] 18 e1
SYS_GETS_BCKSP:
                    dec       hl                            ;[a292] 2b
                    dec       hl                            ;[a293] 2b
                    ld        (hl),$00                      ;[a294] 36 00
                    inc       de                            ;[a296] 13
                    jr        SYS_GETS_LOOP                 ;[a297] 18 da
SYS_GETS_END:
                    jp        SYSCALL_END                   ;[a299] c3 2f a2
SYS_PUTS:
                    call      GET_HL_SYSCALL                ;[a29c] cd 27 a2
SYS_PUTS_LOOP:
                    ld        a,(hl)                        ;[a29f] 7e
                    call      TRANSMIT_CHAR                 ;[a2a0] cd 31 a0
                    inc       hl                            ;[a2a3] 23
                    xor       a                             ;[a2a4] af
                    dec       de                            ;[a2a5] 1b
                    cp        e                             ;[a2a6] bb
                    jr        z,SYS_PUTS_END                ;[a2a7] 28 02
                    jr        SYS_PUTS_LOOP                 ;[a2a9] 18 f4
SYS_PUTS_END:
                    jp        SYSCALL_END                   ;[a2ab] c3 2f a2
SYS_EXEC:
                    call      GET_HL_SYSCALL                ;[a2ae] cd 27 a2
                    ld        ($9014),sp                    ;[a2b1] ed 73 14 90
                    ld        sp,($9004)                    ;[a2b5] ed 7b 04 90
                    pop       bc                            ;[a2b9] c1
                    push      hl                            ;[a2ba] e5
                    ld        sp,($9014)                    ;[a2bb] ed 7b 14 90
                    jp        SYSCALL_END                   ;[a2bf] c3 2f a2
SYS_GETINFO:
                    call      GET_HL_SYSCALL                ;[a2c2] cd 27 a2
                    ex        de,hl                         ;[a2c5] eb
                    ld        hl,$d144                      ;[a2c6] 21 44 d1
                    ld        bc,$0028                      ;[a2c9] 01 28 00
                    ldir                                    ;[a2cc] ed b0
                    jp        SYSCALL_END                   ;[a2ce] c3 2f a2
SYS_RAND:
                    ld        a,r                           ;[a2d1] ed 5f
                    ld        l,a                           ;[a2d3] 6f
                    ld        a,r                           ;[a2d4] ed 5f
                    xor       l                             ;[a2d6] ad
                    ld        h,a                           ;[a2d7] 67
                    call      SAVE_RET                      ;[a2d8] cd 2b a2
                    jp        SYSCALL_END                   ;[a2db] c3 2f a2
SYS_SLEEP:
                    jp        SYSCALL_END                   ;[a2de] c3 2f a2
SYS_FORK:
                    call      GET_HL_SYSCALL                ;[a2e1] cd 27 a2
                    call      CREATE_PROCESS                ;[a2e4] cd 94 a1
                    jp        SYSCALL_END                   ;[a2e7] c3 2f a2
SYS_GETPID:
                    call      GET_HL_SYSCALL                ;[a2ea] cd 27 a2
                    call      GET_PROCESS_ID                ;[a2ed] cd b0 a1
                    ld        l,a                           ;[a2f0] 6f
                    ld        h,$00                         ;[a2f1] 26 00
                    call      SAVE_RET                      ;[a2f3] cd 2b a2
                    jp        SYSCALL_END                   ;[a2f6] c3 2f a2
SYS_GETPCOUNT:
                    call      GET_HL_SYSCALL                ;[a2f9] cd 27 a2
                    ld        hl,($900c)                    ;[a2fc] 2a 0c 90
                    call      SAVE_RET                      ;[a2ff] cd 2b a2
                    jp        SYSCALL_END                   ;[a302] c3 2f a2
SYS_OPEN:
                    call      GET_HL_SYSCALL                ;[a305] cd 27 a2
                    call      _fd_create                    ;[a308] cd c5 af
                    ld        h,$00                         ;[a30b] 26 00
                    call      SAVE_RET                      ;[a30d] cd 2b a2
                    jp        SYSCALL_END                   ;[a310] c3 2f a2
SYS_CLOSE:
                    call      GET_HL_SYSCALL                ;[a313] cd 27 a2
                    call      _fd_close                     ;[a316] cd 9a af
                    ld        h,$00                         ;[a319] 26 00
                    call      SAVE_RET                      ;[a31b] cd 2b a2
                    jp        SYSCALL_END                   ;[a31e] c3 2f a2
SYS_CREATE:
                    call      GET_HL_SYSCALL                ;[a321] cd 27 a2
                    call      _fd_create                    ;[a324] cd c5 af
                    ld        h,$00                         ;[a327] 26 00
                    call      SAVE_RET                      ;[a329] cd 2b a2
                    jp        SYSCALL_END                   ;[a32c] c3 2f a2
SYS_EXECS:
                    call      GET_HL_SYSCALL                ;[a32f] cd 27 a2
                    ex        de,hl                         ;[a332] eb
                    call      _get_file_blockptr            ;[a333] cd 7d aa
                    ld        a,h                           ;[a336] 7c
                    or        l                             ;[a337] b5
                    jp        z,SYS_EXECS_FAIL              ;[a338] ca 55 a3
                    ld        ($9014),sp                    ;[a33b] ed 73 14 90
                    ld        sp,($9004)                    ;[a33f] ed 7b 04 90
                    ld        bc,$0004                      ;[a343] 01 04 00
                    add       hl,bc                         ;[a346] 09
                    pop       bc                            ;[a347] c1
                    push      de                            ;[a348] d5
                    push      hl                            ;[a349] e5
                    ld        ($9004),sp                    ;[a34a] ed 73 04 90
                    ld        sp,($9014)                    ;[a34e] ed 7b 14 90
                    jp        SYSCALL_END                   ;[a352] c3 2f a2
SYS_EXECS_FAIL:
                    ld        hl,$0001                      ;[a355] 21 01 00
                    call      SAVE_RET                      ;[a358] cd 2b a2
                    jp        SYSCALL_END                   ;[a35b] c3 2f a2
_main:
                    ld        hl,$d067                      ;[a35e] 21 67 d0
                    call      _uname                        ;[a361] cd d5 a5
                    call      _mfs_init                     ;[a364] cd ce a9
                    call      _fd_init                      ;[a367] cd 30 af
                    call      _devfs_init                   ;[a36a] cd eb ad
                    call      _fork                         ;[a36d] cd 94 a5
                    ld        hl,$0005                      ;[a370] 21 05 00
                    push      hl                            ;[a373] e5
                    ld        hl,$a637                      ;[a374] 21 37 a6
                    push      hl                            ;[a377] e5
                    ld        hl,$0000                      ;[a378] 21 00 00
                    push      hl                            ;[a37b] e5
                    push      hl                            ;[a37c] e5
                    call      _syscall                      ;[a37d] cd 94 a3
                    pop       bc                            ;[a380] c1
                    pop       bc                            ;[a381] c1
                    pop       bc                            ;[a382] c1
                    pop       bc                            ;[a383] c1
i_2_kernel_kernel_c:
                    nop                                     ;[a384] 00
                    jp        i_2_kernel_kernel_c           ;[a385] c3 84 a3
i_3_kernel_kernel_c:
                    ld        hl,$0000                      ;[a388] 21 00 00
                    push      hl                            ;[a38b] e5
                    call      __exit                        ;[a38c] cd 05 a5
                    pop       bc                            ;[a38f] c1
                    ld        hl,$0000                      ;[a390] 21 00 00
                    ret                                     ;[a393] c9

_syscall:
                    ld        hl,$0008                      ;[a394] 21 08 00
                    add       hl,sp                         ;[a397] 39
                    ld        a,$0f                         ;[a398] 3e 0f
                    sub       (hl)                          ;[a39a] 96
                    jp        nc,i_2_sys_syscall_c          ;[a39b] d2 a2 a3
                    ld        hl,$00ff                      ;[a39e] 21 ff 00
                    ret                                     ;[a3a1] c9

i_2_sys_syscall_c:
                    ld        hl,$0008                      ;[a3a2] 21 08 00
                    add       hl,sp                         ;[a3a5] 39
                    ld        a,(hl)                        ;[a3a6] 7e
                    cp        $01                           ;[a3a7] fe 01
                    jp        nz,i_3_sys_syscall_c          ;[a3a9] c2 c5 a3
                    call      l_gint6sp                     ;[a3ac] cd 80 a0
                    ld        h,$00                         ;[a3af] 26 00
                    push      hl                            ;[a3b1] e5
                    ld        hl,$0006                      ;[a3b2] 21 06 00
                    call      l_gintspsp                    ;[a3b5] cd 5d a0
                    call      l_gint6sp                     ;[a3b8] cd 80 a0
                    push      hl                            ;[a3bb] e5
                    call      _sysc_write                   ;[a3bc] cd fc a3
                    pop       bc                            ;[a3bf] c1
                    pop       bc                            ;[a3c0] c1
                    pop       bc                            ;[a3c1] c1
                    jp        i_5_sys_syscall_c             ;[a3c2] c3 e5 a3
i_3_sys_syscall_c:
                    ld        hl,$0008                      ;[a3c5] 21 08 00
                    add       hl,sp                         ;[a3c8] 39
                    ld        a,(hl)                        ;[a3c9] 7e
                    cp        $02                           ;[a3ca] fe 02
                    jp        nz,i_5_sys_syscall_c          ;[a3cc] c2 e5 a3
                    call      l_gint6sp                     ;[a3cf] cd 80 a0
                    ld        h,$00                         ;[a3d2] 26 00
                    push      hl                            ;[a3d4] e5
                    ld        hl,$0006                      ;[a3d5] 21 06 00
                    call      l_gintspsp                    ;[a3d8] cd 5d a0
                    call      l_gint6sp                     ;[a3db] cd 80 a0
                    push      hl                            ;[a3de] e5
                    call      _sysc_read                    ;[a3df] cd 80 a4
                    pop       bc                            ;[a3e2] c1
                    pop       bc                            ;[a3e3] c1
                    pop       bc                            ;[a3e4] c1
i_5_sys_syscall_c:
                    call      l_gint1sp                     ;[a3e5] cd 6e a0
                    push      hl                            ;[a3e8] e5
                    pop       bc                            ;[a3e9] c1
                    call      l_gint4sp                     ;[a3ea] cd 77 a0
                    push      hl                            ;[a3ed] e5
                    pop       de                            ;[a3ee] d1
                    call      l_gint8sp                     ;[a3ef] cd 89 a0
                    ld        a,l                           ;[a3f2] 7d
                    ex        af,af'                        ;[a3f3] 08
                    call      l_gint6sp                     ;[a3f4] cd 80 a0
                    ex        af,af'                        ;[a3f7] 08
                    call      SYSCALL_DISPATCH              ;[a3f8] cd fc a1
                    ret                                     ;[a3fb] c9

_sysc_write:
                    ld        hl,$0006                      ;[a3fc] 21 06 00
                    add       hl,sp                         ;[a3ff] 39
                    ld        a,(hl)                        ;[a400] 7e
                    cp        $01                           ;[a401] fe 01
                    jp        nz,i_6_sys_syscall_c          ;[a403] c2 1f a4
                    ld        hl,$0004                      ;[a406] 21 04 00
                    push      hl                            ;[a409] e5
                    call      l_gintspsp                    ;[a40a] cd 5d a0
                    ld        hl,$0008                      ;[a40d] 21 08 00
                    call      l_gintspsp                    ;[a410] cd 5d a0
                    ld        hl,$0000                      ;[a413] 21 00 00
                    push      hl                            ;[a416] e5
                    call      _syscall                      ;[a417] cd 94 a3
                    pop       bc                            ;[a41a] c1
                    pop       bc                            ;[a41b] c1
                    pop       bc                            ;[a41c] c1
                    pop       bc                            ;[a41d] c1
                    ret                                     ;[a41e] c9

i_6_sys_syscall_c:
                    ld        hl,$0006                      ;[a41f] 21 06 00
                    add       hl,sp                         ;[a422] 39
                    ld        l,(hl)                        ;[a423] 6e
                    ld        h,$00                         ;[a424] 26 00
                    ld        a,l                           ;[a426] 7d
                    cp        $ff                           ;[a427] fe ff
                    jp        nz,i_8_sys_syscall_c          ;[a429] c2 2d a4
                    ret                                     ;[a42c] c9

i_8_sys_syscall_c:
                    push      bc                            ;[a42d] c5
                    ld        hl,$0008                      ;[a42e] 21 08 00
                    add       hl,sp                         ;[a431] 39
                    ld        l,(hl)                        ;[a432] 6e
                    ld        h,$00                         ;[a433] 26 00
                    push      hl                            ;[a435] e5
                    ld        hl,$0000                      ;[a436] 21 00 00
                    push      hl                            ;[a439] e5
                    ld        l,$04                         ;[a43a] 2e 04
                    add       hl,sp                         ;[a43c] 39
                    push      hl                            ;[a43d] e5
                    call      _fd_get                       ;[a43e] cd 58 b0
                    pop       bc                            ;[a441] c1
                    pop       bc                            ;[a442] c1
                    pop       bc                            ;[a443] c1
                    ld        hl,$0000                      ;[a444] 21 00 00
                    push      hl                            ;[a447] e5
                    jp        i_12_sys_syscall_c            ;[a448] c3 4e a4
i_10_sys_syscall_c:
                    pop       hl                            ;[a44b] e1
                    inc       hl                            ;[a44c] 23
                    push      hl                            ;[a44d] e5
i_12_sys_syscall_c:
                    pop       de                            ;[a44e] d1
                    push      de                            ;[a44f] d5
                    call      l_gint8sp                     ;[a450] cd 89 a0
                    ex        de,hl                         ;[a453] eb
                    and       a                             ;[a454] a7
                    sbc       hl,de                         ;[a455] ed 52
                    jp        nc,i_11_sys_syscall_c         ;[a457] d2 7d a4
                    ld        hl,$0002                      ;[a45a] 21 02 00
                    call      l_gintspsp                    ;[a45d] cd 5d a0
                    pop       bc                            ;[a460] c1
                    pop       hl                            ;[a461] e1
                    push      hl                            ;[a462] e5
                    push      bc                            ;[a463] c5
                    add       hl,hl                         ;[a464] 29
                    pop       de                            ;[a465] d1
                    add       hl,de                         ;[a466] 19
                    push      hl                            ;[a467] e5
                    ld        hl,$0008                      ;[a468] 21 08 00
                    call      l_gintspsp                    ;[a46b] cd 5d a0
                    call      l_gint4sp                     ;[a46e] cd 77 a0
                    pop       de                            ;[a471] d1
                    add       hl,de                         ;[a472] 19
                    ld        l,(hl)                        ;[a473] 6e
                    ld        h,$00                         ;[a474] 26 00
                    pop       de                            ;[a476] d1
                    call      l_pint                        ;[a477] cd 95 a0
                    jp        i_10_sys_syscall_c            ;[a47a] c3 4b a4
i_11_sys_syscall_c:
                    pop       bc                            ;[a47d] c1
                    pop       bc                            ;[a47e] c1
i_9_sys_syscall_c:
                    ret                                     ;[a47f] c9

_sysc_read:
                    ld        hl,$0006                      ;[a480] 21 06 00
                    add       hl,sp                         ;[a483] 39
                    ld        a,(hl)                        ;[a484] 7e
                    and       a                             ;[a485] a7
                    jp        nz,i_13_sys_syscall_c         ;[a486] c2 a4 a4
                    ld        hl,$0003                      ;[a489] 21 03 00
                    push      hl                            ;[a48c] e5
                    ld        l,$04                         ;[a48d] 2e 04
                    call      l_gintspsp                    ;[a48f] cd 5d a0
                    ld        hl,$0008                      ;[a492] 21 08 00
                    call      l_gintspsp                    ;[a495] cd 5d a0
                    ld        hl,$0000                      ;[a498] 21 00 00
                    push      hl                            ;[a49b] e5
                    call      _syscall                      ;[a49c] cd 94 a3
                    pop       bc                            ;[a49f] c1
                    pop       bc                            ;[a4a0] c1
                    pop       bc                            ;[a4a1] c1
                    pop       bc                            ;[a4a2] c1
                    ret                                     ;[a4a3] c9

i_13_sys_syscall_c:
                    ld        hl,$0006                      ;[a4a4] 21 06 00
                    add       hl,sp                         ;[a4a7] 39
                    ld        l,(hl)                        ;[a4a8] 6e
                    ld        h,$00                         ;[a4a9] 26 00
                    ld        a,l                           ;[a4ab] 7d
                    cp        $ff                           ;[a4ac] fe ff
                    jp        nz,i_15_sys_syscall_c         ;[a4ae] c2 b2 a4
                    ret                                     ;[a4b1] c9

i_15_sys_syscall_c:
                    push      bc                            ;[a4b2] c5
                    ld        hl,$0008                      ;[a4b3] 21 08 00
                    add       hl,sp                         ;[a4b6] 39
                    ld        l,(hl)                        ;[a4b7] 6e
                    ld        h,$00                         ;[a4b8] 26 00
                    push      hl                            ;[a4ba] e5
                    ld        hl,$0002                      ;[a4bb] 21 02 00
                    add       hl,sp                         ;[a4be] 39
                    push      hl                            ;[a4bf] e5
                    ld        hl,$0000                      ;[a4c0] 21 00 00
                    push      hl                            ;[a4c3] e5
                    call      _fd_get                       ;[a4c4] cd 58 b0
                    pop       bc                            ;[a4c7] c1
                    pop       bc                            ;[a4c8] c1
                    pop       bc                            ;[a4c9] c1
                    ld        hl,$0000                      ;[a4ca] 21 00 00
                    push      hl                            ;[a4cd] e5
                    jp        i_19_sys_syscall_c            ;[a4ce] c3 d4 a4
i_17_sys_syscall_c:
                    pop       hl                            ;[a4d1] e1
                    inc       hl                            ;[a4d2] 23
                    push      hl                            ;[a4d3] e5
i_19_sys_syscall_c:
                    pop       de                            ;[a4d4] d1
                    push      de                            ;[a4d5] d5
                    call      l_gint8sp                     ;[a4d6] cd 89 a0
                    ex        de,hl                         ;[a4d9] eb
                    and       a                             ;[a4da] a7
                    sbc       hl,de                         ;[a4db] ed 52
                    jp        nc,i_18_sys_syscall_c         ;[a4dd] d2 02 a5
                    ld        hl,$0006                      ;[a4e0] 21 06 00
                    call      l_gintspsp                    ;[a4e3] cd 5d a0
                    pop       bc                            ;[a4e6] c1
                    pop       hl                            ;[a4e7] e1
                    push      hl                            ;[a4e8] e5
                    push      bc                            ;[a4e9] c5
                    pop       de                            ;[a4ea] d1
                    add       hl,de                         ;[a4eb] 19
                    push      hl                            ;[a4ec] e5
                    ld        hl,$0004                      ;[a4ed] 21 04 00
                    call      l_gintspsp                    ;[a4f0] cd 5d a0
                    call      l_gint4sp                     ;[a4f3] cd 77 a0
                    add       hl,hl                         ;[a4f6] 29
                    pop       de                            ;[a4f7] d1
                    add       hl,de                         ;[a4f8] 19
                    call      l_gint                        ;[a4f9] cd 69 a0
                    pop       de                            ;[a4fc] d1
                    ld        a,l                           ;[a4fd] 7d
                    ld        (de),a                        ;[a4fe] 12
                    jp        i_17_sys_syscall_c            ;[a4ff] c3 d1 a4
i_18_sys_syscall_c:
                    pop       bc                            ;[a502] c1
                    pop       bc                            ;[a503] c1
i_16_sys_syscall_c:
                    ret                                     ;[a504] c9

__exit:
                    ld        hl,$0000                      ;[a505] 21 00 00
                    push      hl                            ;[a508] e5
                    ld        l,$04                         ;[a509] 2e 04
                    call      l_gintspsp                    ;[a50b] cd 5d a0
                    ld        hl,$0000                      ;[a50e] 21 00 00
                    push      hl                            ;[a511] e5
                    push      hl                            ;[a512] e5
                    call      _syscall                      ;[a513] cd 94 a3
                    pop       bc                            ;[a516] c1
                    pop       bc                            ;[a517] c1
                    pop       bc                            ;[a518] c1
                    pop       bc                            ;[a519] c1
                    ret                                     ;[a51a] c9

_read:
                    call      l_gint6sp                     ;[a51b] cd 80 a0
                    ld        a,h                           ;[a51e] 7c
                    or        l                             ;[a51f] b5
                    jp        nz,i_2_sys_unistd_c           ;[a520] c2 3a a5
                    ld        hl,$0003                      ;[a523] 21 03 00
                    push      hl                            ;[a526] e5
                    ld        l,$06                         ;[a527] 2e 06
                    call      l_g2intspsp                   ;[a529] cd 4a a0
                    ld        hl,$0000                      ;[a52c] 21 00 00
                    push      hl                            ;[a52f] e5
                    call      _syscall                      ;[a530] cd 94 a3
                    pop       bc                            ;[a533] c1
                    pop       bc                            ;[a534] c1
                    pop       bc                            ;[a535] c1
                    pop       bc                            ;[a536] c1
                    jp        i_3_sys_unistd_c              ;[a537] c3 52 a5
i_2_sys_unistd_c:
                    ld        hl,$0002                      ;[a53a] 21 02 00
                    push      hl                            ;[a53d] e5
                    ld        l,$06                         ;[a53e] 2e 06
                    call      l_g2intspsp                   ;[a540] cd 4a a0
                    ld        hl,$000c                      ;[a543] 21 0c 00
                    add       hl,sp                         ;[a546] 39
                    call      l_gint                        ;[a547] cd 69 a0
                    push      hl                            ;[a54a] e5
                    call      _syscall                      ;[a54b] cd 94 a3
                    pop       bc                            ;[a54e] c1
                    pop       bc                            ;[a54f] c1
                    pop       bc                            ;[a550] c1
                    pop       bc                            ;[a551] c1
i_3_sys_unistd_c:
                    pop       bc                            ;[a552] c1
                    pop       hl                            ;[a553] e1
                    push      hl                            ;[a554] e5
                    push      bc                            ;[a555] c5
                    ret                                     ;[a556] c9

_write:
                    call      l_gint6sp                     ;[a557] cd 80 a0
                    dec       hl                            ;[a55a] 2b
                    ld        a,h                           ;[a55b] 7c
                    or        l                             ;[a55c] b5
                    jp        nz,i_4_sys_unistd_c           ;[a55d] c2 77 a5
                    ld        hl,$0004                      ;[a560] 21 04 00
                    push      hl                            ;[a563] e5
                    ld        l,$06                         ;[a564] 2e 06
                    call      l_g2intspsp                   ;[a566] cd 4a a0
                    ld        hl,$0000                      ;[a569] 21 00 00
                    push      hl                            ;[a56c] e5
                    call      _syscall                      ;[a56d] cd 94 a3
                    pop       bc                            ;[a570] c1
                    pop       bc                            ;[a571] c1
                    pop       bc                            ;[a572] c1
                    pop       bc                            ;[a573] c1
                    jp        i_5_sys_unistd_c              ;[a574] c3 8f a5
i_4_sys_unistd_c:
                    ld        hl,$0001                      ;[a577] 21 01 00
                    push      hl                            ;[a57a] e5
                    ld        l,$06                         ;[a57b] 2e 06
                    call      l_g2intspsp                   ;[a57d] cd 4a a0
                    ld        hl,$000c                      ;[a580] 21 0c 00
                    add       hl,sp                         ;[a583] 39
                    call      l_gint                        ;[a584] cd 69 a0
                    push      hl                            ;[a587] e5
                    call      _syscall                      ;[a588] cd 94 a3
                    pop       bc                            ;[a58b] c1
                    pop       bc                            ;[a58c] c1
                    pop       bc                            ;[a58d] c1
                    pop       bc                            ;[a58e] c1
i_5_sys_unistd_c:
                    pop       bc                            ;[a58f] c1
                    pop       hl                            ;[a590] e1
                    push      hl                            ;[a591] e5
                    push      bc                            ;[a592] c5
                    ret                                     ;[a593] c9

_fork:
                    ld        hl,$0009                      ;[a594] 21 09 00
                    push      hl                            ;[a597] e5
                    ld        l,$00                         ;[a598] 2e 00
                    push      hl                            ;[a59a] e5
                    ld        de,$0000                      ;[a59b] 11 00 00
                    push      de                            ;[a59e] d5
                    push      hl                            ;[a59f] e5
                    call      _syscall                      ;[a5a0] cd 94 a3
                    pop       bc                            ;[a5a3] c1
                    pop       bc                            ;[a5a4] c1
                    pop       bc                            ;[a5a5] c1
                    pop       bc                            ;[a5a6] c1
                    ld        hl,$0000                      ;[a5a7] 21 00 00
                    ret                                     ;[a5aa] c9

_getpid:
                    ld        hl,$000a                      ;[a5ab] 21 0a 00
                    push      hl                            ;[a5ae] e5
                    ld        l,$00                         ;[a5af] 2e 00
                    push      hl                            ;[a5b1] e5
                    ld        de,$0000                      ;[a5b2] 11 00 00
                    push      de                            ;[a5b5] d5
                    push      hl                            ;[a5b6] e5
                    call      _syscall                      ;[a5b7] cd 94 a3
                    pop       bc                            ;[a5ba] c1
                    pop       bc                            ;[a5bb] c1
                    pop       bc                            ;[a5bc] c1
                    pop       bc                            ;[a5bd] c1
                    ret                                     ;[a5be] c9

_close:
                    ld        hl,$000d                      ;[a5bf] 21 0d 00
                    push      hl                            ;[a5c2] e5
                    ld        l,$04                         ;[a5c3] 2e 04
                    call      l_gintspsp                    ;[a5c5] cd 5d a0
                    ld        hl,$0000                      ;[a5c8] 21 00 00
                    push      hl                            ;[a5cb] e5
                    push      hl                            ;[a5cc] e5
                    call      _syscall                      ;[a5cd] cd 94 a3
                    pop       bc                            ;[a5d0] c1
                    pop       bc                            ;[a5d1] c1
                    pop       bc                            ;[a5d2] c1
                    pop       bc                            ;[a5d3] c1
                    ret                                     ;[a5d4] c9

_uname:
                    push      hl                            ;[a5d5] e5
                    ld        hl,$0006                      ;[a5d6] 21 06 00
                    push      hl                            ;[a5d9] e5
                    ld        hl,$d08f                      ;[a5da] 21 8f d0
                    push      hl                            ;[a5dd] e5
                    ld        hl,$0028                      ;[a5de] 21 28 00
                    push      hl                            ;[a5e1] e5
                    ld        l,$00                         ;[a5e2] 2e 00
                    push      hl                            ;[a5e4] e5
                    call      _syscall                      ;[a5e5] cd 94 a3
                    pop       bc                            ;[a5e8] c1
                    pop       bc                            ;[a5e9] c1
                    pop       bc                            ;[a5ea] c1
                    pop       bc                            ;[a5eb] c1
                    dec       sp                            ;[a5ec] 3b
                    pop       hl                            ;[a5ed] e1
                    ld        l,$07                         ;[a5ee] 2e 07
                    push      hl                            ;[a5f0] e5
                    jp        i_4_sys_utsname_c             ;[a5f1] c3 fc a5
i_2_sys_utsname_c:
                    pop       hl                            ;[a5f4] e1
                    ld        a,l                           ;[a5f5] 7d
                    add       $08                           ;[a5f6] c6 08
                    ld        l,a                           ;[a5f8] 6f
                    push      hl                            ;[a5f9] e5
                    ld        h,$00                         ;[a5fa] 26 00
i_4_sys_utsname_c:
                    pop       hl                            ;[a5fc] e1
                    push      hl                            ;[a5fd] e5
                    ld        a,l                           ;[a5fe] 7d
                    sub       $28                           ;[a5ff] d6 28
                    jp        nc,i_3_sys_utsname_c          ;[a601] d2 11 a6
                    ld        de,$d08f                      ;[a604] 11 8f d0
                    pop       hl                            ;[a607] e1
                    push      hl                            ;[a608] e5
                    ld        h,$00                         ;[a609] 26 00
                    add       hl,de                         ;[a60b] 19
                    ld        (hl),$00                      ;[a60c] 36 00
                    jp        i_2_sys_utsname_c             ;[a60e] c3 f4 a5
i_3_sys_utsname_c:
                    inc       sp                            ;[a611] 33
                    pop       de                            ;[a612] d1
                    push      de                            ;[a613] d5
                    ld        hl,$d08f                      ;[a614] 21 8f d0
                    ld        bc,$0028                      ;[a617] 01 28 00
                    ldir                                    ;[a61a] ed b0
                    ld        hl,$0000                      ;[a61c] 21 00 00
                    pop       bc                            ;[a61f] c1
                    ret                                     ;[a620] c9

_newline:
                    ld        hl,$b13d                      ;[a621] 21 3d b1
                    call      _puts                         ;[a624] cd 7f a8
                    ret                                     ;[a627] c9

_testfunc:
                    ld        hl,$b140                      ;[a628] 21 40 b1
                    call      _puts                         ;[a62b] cd 7f a8
                    ld        hl,$0003                      ;[a62e] 21 03 00
                    push      hl                            ;[a631] e5
                    call      __exit                        ;[a632] cd 05 a5
                    pop       bc                            ;[a635] c1
                    ret                                     ;[a636] c9

_terminal:
                    ld        hl,$d067                      ;[a637] 21 67 d0
                    call      _puts                         ;[a63a] cd 7f a8
                    ld        hl,$d077                      ;[a63d] 21 77 d0
                    call      _puts                         ;[a640] cd 7f a8
                    call      _newline                      ;[a643] cd 21 a6
i_22:
                    ld        hl,$d0b7                      ;[a646] 21 b7 d0
                    push      hl                            ;[a649] e5
                    ld        e,$00                         ;[a64a] 1e 00
                    ld        b,$20                         ;[a64c] 06 20
i_4_sys_shell_c:
                    ld        (hl),e                        ;[a64e] 73
                    inc       hl                            ;[a64f] 23
                    djnz      i_4_sys_shell_c               ;[a650] 10 fc
                    pop       hl                            ;[a652] e1
                    ld        hl,$b157                      ;[a653] 21 57 b1
                    call      _puts                         ;[a656] cd 7f a8
                    ld        hl,$0000                      ;[a659] 21 00 00
                    push      hl                            ;[a65c] e5
                    ld        hl,$d0b7                      ;[a65d] 21 b7 d0
                    push      hl                            ;[a660] e5
                    ld        hl,$0020                      ;[a661] 21 20 00
                    push      hl                            ;[a664] e5
                    call      _read                         ;[a665] cd 1b a5
                    pop       bc                            ;[a668] c1
                    pop       bc                            ;[a669] c1
                    pop       bc                            ;[a66a] c1
                    call      _newline                      ;[a66b] cd 21 a6
                    ld        hl,$d0b7                      ;[a66e] 21 b7 d0
                    push      hl                            ;[a671] e5
                    ld        hl,$b15a                      ;[a672] 21 5a b1
                    push      hl                            ;[a675] e5
                    call      ___strcmp_callee              ;[a676] cd fd b0
                    ld        a,h                           ;[a679] 7c
                    or        l                             ;[a67a] b5
                    jp        nz,i_5_sys_shell_c            ;[a67b] c2 86 a6
                    push      hl                            ;[a67e] e5
                    call      __exit                        ;[a67f] cd 05 a5
                    pop       bc                            ;[a682] c1
                    jp        i_22                          ;[a683] c3 46 a6
i_5_sys_shell_c:
                    ld        hl,$d0b7                      ;[a686] 21 b7 d0
                    push      hl                            ;[a689] e5
                    ld        hl,$b15f                      ;[a68a] 21 5f b1
                    push      hl                            ;[a68d] e5
                    call      ___strcmp_callee              ;[a68e] cd fd b0
                    ld        a,h                           ;[a691] 7c
                    or        l                             ;[a692] b5
                    jp        nz,i_7_sys_shell_c            ;[a693] c2 b2 a6
                    ld        hl,$0004                      ;[a696] 21 04 00
                    push      hl                            ;[a699] e5
                    ld        hl,$d067                      ;[a69a] 21 67 d0
                    push      hl                            ;[a69d] e5
                    ld        hl,$0028                      ;[a69e] 21 28 00
                    push      hl                            ;[a6a1] e5
                    ld        l,$00                         ;[a6a2] 2e 00
                    push      hl                            ;[a6a4] e5
                    call      _syscall                      ;[a6a5] cd 94 a3
                    pop       bc                            ;[a6a8] c1
                    pop       bc                            ;[a6a9] c1
                    pop       bc                            ;[a6aa] c1
                    pop       bc                            ;[a6ab] c1
                    call      _newline                      ;[a6ac] cd 21 a6
                    jp        i_22                          ;[a6af] c3 46 a6
i_7_sys_shell_c:
                    ld        hl,$d0b7                      ;[a6b2] 21 b7 d0
                    push      hl                            ;[a6b5] e5
                    ld        hl,$b165                      ;[a6b6] 21 65 b1
                    push      hl                            ;[a6b9] e5
                    call      ___strcmp_callee              ;[a6ba] cd fd b0
                    ld        a,h                           ;[a6bd] 7c
                    or        l                             ;[a6be] b5
                    jp        nz,i_9_sys_shell_c            ;[a6bf] c2 cb a6
                    ld        hl,$000c                      ;[a6c2] 21 0c 00
                    call      _putchar                      ;[a6c5] cd 75 a8
                    jp        i_22                          ;[a6c8] c3 46 a6
i_9_sys_shell_c:
                    ld        hl,$d0b7                      ;[a6cb] 21 b7 d0
                    push      hl                            ;[a6ce] e5
                    ld        hl,$b16b                      ;[a6cf] 21 6b b1
                    push      hl                            ;[a6d2] e5
                    call      ___strcmp_callee              ;[a6d3] cd fd b0
                    ld        a,h                           ;[a6d6] 7c
                    or        l                             ;[a6d7] b5
                    jp        nz,i_11_sys_shell_c           ;[a6d8] c2 ff a6
                    ld        hl,$000a                      ;[a6db] 21 0a 00
                    push      hl                            ;[a6de] e5
                    ld        l,$00                         ;[a6df] 2e 00
                    push      hl                            ;[a6e1] e5
                    ld        de,$0000                      ;[a6e2] 11 00 00
                    push      de                            ;[a6e5] d5
                    push      hl                            ;[a6e6] e5
                    call      _syscall                      ;[a6e7] cd 94 a3
                    pop       bc                            ;[a6ea] c1
                    pop       bc                            ;[a6eb] c1
                    pop       bc                            ;[a6ec] c1
                    pop       bc                            ;[a6ed] c1
                    ld        a,l                           ;[a6ee] 7d
                    ld        hl,$d196                      ;[a6ef] 21 96 d1
                    ld        (hl),a                        ;[a6f2] 77
                    ld        l,(hl)                        ;[a6f3] 6e
                    ld        h,$00                         ;[a6f4] 26 00
                    call      _putn                         ;[a6f6] cd a3 a8
                    call      _newline                      ;[a6f9] cd 21 a6
                    jp        i_22                          ;[a6fc] c3 46 a6
i_11_sys_shell_c:
                    ld        hl,$d0b7                      ;[a6ff] 21 b7 d0
                    push      hl                            ;[a702] e5
                    ld        hl,$b16f                      ;[a703] 21 6f b1
                    push      hl                            ;[a706] e5
                    call      ___strcmp_callee              ;[a707] cd fd b0
                    ld        a,h                           ;[a70a] 7c
                    or        l                             ;[a70b] b5
                    jp        nz,i_14_sys_shell_c           ;[a70c] c2 33 a7
                    ld        hl,$000b                      ;[a70f] 21 0b 00
                    push      hl                            ;[a712] e5
                    ld        l,$00                         ;[a713] 2e 00
                    push      hl                            ;[a715] e5
                    ld        de,$0000                      ;[a716] 11 00 00
                    push      de                            ;[a719] d5
                    push      hl                            ;[a71a] e5
                    call      _syscall                      ;[a71b] cd 94 a3
                    pop       bc                            ;[a71e] c1
                    pop       bc                            ;[a71f] c1
                    pop       bc                            ;[a720] c1
                    pop       bc                            ;[a721] c1
                    ld        a,l                           ;[a722] 7d
                    ld        hl,$d197                      ;[a723] 21 97 d1
                    ld        (hl),a                        ;[a726] 77
                    ld        l,(hl)                        ;[a727] 6e
                    ld        h,$00                         ;[a728] 26 00
                    call      _putn                         ;[a72a] cd a3 a8
                    call      _newline                      ;[a72d] cd 21 a6
                    jp        i_22                          ;[a730] c3 46 a6
i_14_sys_shell_c:
                    ld        hl,$d0b7                      ;[a733] 21 b7 d0
                    push      hl                            ;[a736] e5
                    ld        hl,$b176                      ;[a737] 21 76 b1
                    push      hl                            ;[a73a] e5
                    call      ___strcmp_callee              ;[a73b] cd fd b0
                    ld        a,h                           ;[a73e] 7c
                    or        l                             ;[a73f] b5
                    jp        nz,i_17_sys_shell_c           ;[a740] c2 49 a7
                    call      _print_devices                ;[a743] cd 50 ae
                    jp        i_22                          ;[a746] c3 46 a6
i_17_sys_shell_c:
                    ld        hl,$d0b7                      ;[a749] 21 b7 d0
                    push      hl                            ;[a74c] e5
                    ld        hl,$b17c                      ;[a74d] 21 7c b1
                    push      hl                            ;[a750] e5
                    call      ___strcmp_callee              ;[a751] cd fd b0
                    ld        a,h                           ;[a754] 7c
                    or        l                             ;[a755] b5
                    jp        nz,i_19_sys_shell_c           ;[a756] c2 5f a7
                    call      _list_files                   ;[a759] cd 87 ad
                    jp        i_22                          ;[a75c] c3 46 a6
i_19_sys_shell_c:
                    ld        hl,$d0b7                      ;[a75f] 21 b7 d0
                    push      hl                            ;[a762] e5
                    ld        hl,$b17f                      ;[a763] 21 7f b1
                    push      hl                            ;[a766] e5
                    call      ___strcmp_callee              ;[a767] cd fd b0
                    ld        a,h                           ;[a76a] 7c
                    or        l                             ;[a76b] b5
                    jp        nz,i_21_sys_shell_c           ;[a76c] c2 75 a7
                    call      REG_DUMP                      ;[a76f] cd 0e a1
                    jp        i_22                          ;[a772] c3 46 a6
i_21_sys_shell_c:
                    ld        hl,$b185                      ;[a775] 21 85 b1
                    push      hl                            ;[a778] e5
                    ld        hl,$d0b7                      ;[a779] 21 b7 d0
                    push      hl                            ;[a77c] e5
                    call      ___strcmp_callee              ;[a77d] cd fd b0
                    ld        a,h                           ;[a780] 7c
                    or        l                             ;[a781] b5
                    jp        nz,i_23_sys_shell_c           ;[a782] c2 0d a8
                    ld        hl,$b18a                      ;[a785] 21 8a b1
                    call      _create_file                  ;[a788] cd 9e ac
                    ld        hl,$b18a                      ;[a78b] 21 8a b1
                    push      hl                            ;[a78e] e5
                    ld        hl,$000d                      ;[a78f] 21 0d 00
                    push      hl                            ;[a792] e5
                    ld        hl,$d198                      ;[a793] 21 98 d1
                    push      hl                            ;[a796] e5
                    call      _write_file                   ;[a797] cd 9e ab
                    pop       bc                            ;[a79a] c1
                    pop       bc                            ;[a79b] c1
                    pop       bc                            ;[a79c] c1
                    ld        hl,$b18a                      ;[a79d] 21 8a b1
                    call      _get_file_blockptr            ;[a7a0] cd 7d aa
                    push      hl                            ;[a7a3] e5
                    ld        de,$0000                      ;[a7a4] 11 00 00
                    call      l_eq                          ;[a7a7] cd 40 a0
                    jp        nc,i_25_sys_shell_c           ;[a7aa] d2 b7 a7
                    ld        hl,$b192                      ;[a7ad] 21 92 b1
                    call      _puts                         ;[a7b0] cd 7f a8
                    pop       bc                            ;[a7b3] c1
                    jp        i_22                          ;[a7b4] c3 46 a6
i_25_sys_shell_c:
                    pop       hl                            ;[a7b7] e1
                    ld        bc,$0008                      ;[a7b8] 01 08 00
                    add       hl,bc                         ;[a7bb] 09
                    push      hl                            ;[a7bc] e5
                    dec       sp                            ;[a7bd] 3b
                    pop       hl                            ;[a7be] e1
                    ld        l,$00                         ;[a7bf] 2e 00
                    push      hl                            ;[a7c1] e5
                    jp        i_28_sys_shell_c              ;[a7c2] c3 ca a7
i_26_sys_shell_c:
                    ld        hl,$0000                      ;[a7c5] 21 00 00
                    add       hl,sp                         ;[a7c8] 39
                    inc       (hl)                          ;[a7c9] 34
i_28_sys_shell_c:
                    pop       hl                            ;[a7ca] e1
                    push      hl                            ;[a7cb] e5
                    ld        h,$00                         ;[a7cc] 26 00
                    ld        de,$000d                      ;[a7ce] 11 0d 00
                    and       a                             ;[a7d1] a7
                    sbc       hl,de                         ;[a7d2] ed 52
                    jp        nc,i_27_sys_shell_c           ;[a7d4] d2 f0 a7
                    ld        hl,$0001                      ;[a7d7] 21 01 00
                    call      l_gintspsp                    ;[a7da] cd 5d a0
                    ld        hl,$0002                      ;[a7dd] 21 02 00
                    add       hl,sp                         ;[a7e0] 39
                    ld        l,(hl)                        ;[a7e1] 6e
                    ld        h,$00                         ;[a7e2] 26 00
                    add       hl,hl                         ;[a7e4] 29
                    pop       de                            ;[a7e5] d1
                    add       hl,de                         ;[a7e6] 19
                    call      l_gint                        ;[a7e7] cd 69 a0
                    call      _puth                         ;[a7ea] cd 49 a9
                    jp        i_26_sys_shell_c              ;[a7ed] c3 c5 a7
i_27_sys_shell_c:
                    inc       sp                            ;[a7f0] 33
                    call      _fork                         ;[a7f1] cd 94 a5
                    ld        hl,$0005                      ;[a7f4] 21 05 00
                    push      hl                            ;[a7f7] e5
                    ld        l,$02                         ;[a7f8] 2e 02
                    call      l_gintspsp                    ;[a7fa] cd 5d a0
                    ld        hl,$0000                      ;[a7fd] 21 00 00
                    push      hl                            ;[a800] e5
                    push      hl                            ;[a801] e5
                    call      _syscall                      ;[a802] cd 94 a3
                    pop       bc                            ;[a805] c1
                    pop       bc                            ;[a806] c1
                    pop       bc                            ;[a807] c1
                    pop       bc                            ;[a808] c1
                    pop       bc                            ;[a809] c1
                    jp        i_22                          ;[a80a] c3 46 a6
i_23_sys_shell_c:
                    ld        hl,$b1b5                      ;[a80d] 21 b5 b1
                    push      hl                            ;[a810] e5
                    ld        hl,$d0b7                      ;[a811] 21 b7 d0
                    push      hl                            ;[a814] e5
                    call      ___strcmp_callee              ;[a815] cd fd b0
                    ld        a,h                           ;[a818] 7c
                    or        l                             ;[a819] b5
                    jp        nz,i_30_sys_shell_c           ;[a81a] c2 25 a8
                    push      hl                            ;[a81d] e5
                    call      __exit                        ;[a81e] cd 05 a5
                    pop       bc                            ;[a821] c1
                    jp        i_22                          ;[a822] c3 46 a6
i_30_sys_shell_c:
                    ld        hl,$b1b9                      ;[a825] 21 b9 b1
                    push      hl                            ;[a828] e5
                    ld        hl,$d0b7                      ;[a829] 21 b7 d0
                    push      hl                            ;[a82c] e5
                    call      ___strcmp_callee              ;[a82d] cd fd b0
                    ld        a,h                           ;[a830] 7c
                    or        l                             ;[a831] b5
                    jp        nz,i_32_sys_shell_c           ;[a832] c2 41 a8
                    ld        hl,($900e)                    ;[a835] 2a 0e 90
                    call      _puth                         ;[a838] cd 49 a9
                    call      _newline                      ;[a83b] cd 21 a6
                    jp        i_22                          ;[a83e] c3 46 a6
i_32_sys_shell_c:
                    ld        hl,$b1bc                      ;[a841] 21 bc b1
                    push      hl                            ;[a844] e5
                    ld        hl,$d0b7                      ;[a845] 21 b7 d0
                    push      hl                            ;[a848] e5
                    call      ___strcmp_callee              ;[a849] cd fd b0
                    ld        a,h                           ;[a84c] 7c
                    or        l                             ;[a84d] b5
                    jp        nz,i_34_sys_shell_c           ;[a84e] c2 6b a8
                    call      _fork                         ;[a851] cd 94 a5
                    ld        hl,$0005                      ;[a854] 21 05 00
                    push      hl                            ;[a857] e5
                    ld        hl,$a628                      ;[a858] 21 28 a6
                    push      hl                            ;[a85b] e5
                    ld        hl,$0000                      ;[a85c] 21 00 00
                    push      hl                            ;[a85f] e5
                    push      hl                            ;[a860] e5
                    call      _syscall                      ;[a861] cd 94 a3
                    pop       bc                            ;[a864] c1
                    pop       bc                            ;[a865] c1
                    pop       bc                            ;[a866] c1
                    pop       bc                            ;[a867] c1
                    jp        i_22                          ;[a868] c3 46 a6
i_34_sys_shell_c:
                    ld        hl,$b1c5                      ;[a86b] 21 c5 b1
                    call      _puts                         ;[a86e] cd 7f a8
                    jp        i_22                          ;[a871] c3 46 a6
i_3_sys_shell_c:
                    ret                                     ;[a874] c9

_putchar:
                    push      hl                            ;[a875] e5
                    ld        a,l                           ;[a876] 7d
                    call      _fputc_cons                   ;[a877] cd 0b a0
                    ld        hl,$0000                      ;[a87a] 21 00 00
                    pop       bc                            ;[a87d] c1
                    ret                                     ;[a87e] c9

_puts:
                    push      hl                            ;[a87f] e5
                    call      ___strlen_fastcall            ;[a880] cd 1d b1
                    push      hl                            ;[a883] e5
                    ld        hl,$0004                      ;[a884] 21 04 00
                    push      hl                            ;[a887] e5
                    call      l_g2intspsp                   ;[a888] cd 4a a0
                    ld        hl,$0000                      ;[a88b] 21 00 00
                    push      hl                            ;[a88e] e5
                    call      _syscall                      ;[a88f] cd 94 a3
                    pop       bc                            ;[a892] c1
                    pop       bc                            ;[a893] c1
                    pop       bc                            ;[a894] c1
                    pop       bc                            ;[a895] c1
                    ld        hl,$0000                      ;[a896] 21 00 00
                    pop       bc                            ;[a899] c1
                    pop       bc                            ;[a89a] c1
                    ret                                     ;[a89b] c9

_getchar:
                    call      _fgetc_cons                   ;[a89c] cd 0f a0
                    ld        l,a                           ;[a89f] 6f
                    ld        h,$00                         ;[a8a0] 26 00
                    ret                                     ;[a8a2] c9

_putn:
                    push      hl                            ;[a8a3] e5
                    ld        hl,$0000                      ;[a8a4] 21 00 00
                    push      hl                            ;[a8a7] e5
                    dec       sp                            ;[a8a8] 3b
                    ld        a,l                           ;[a8a9] 7d
                    pop       hl                            ;[a8aa] e1
                    ld        l,a                           ;[a8ab] 6f
                    push      hl                            ;[a8ac] e5
                    jp        i_5_include_stdio_c           ;[a8ad] c3 b5 a8
i_3_include_stdio_c:
                    ld        hl,$0000                      ;[a8b0] 21 00 00
                    add       hl,sp                         ;[a8b3] 39
                    inc       (hl)                          ;[a8b4] 34
i_5_include_stdio_c:
                    pop       hl                            ;[a8b5] e1
                    push      hl                            ;[a8b6] e5
                    ld        a,l                           ;[a8b7] 7d
                    sub       $05                           ;[a8b8] d6 05
                    jp        nc,i_4_include_stdio_c        ;[a8ba] d2 45 a9
                    dec       sp                            ;[a8bd] 3b
                    pop       hl                            ;[a8be] e1
                    ld        l,$00                         ;[a8bf] 2e 00
                    push      hl                            ;[a8c1] e5
i_6_include_stdio_c:
                    call      l_gint4sp                     ;[a8c2] cd 77 a0
                    push      hl                            ;[a8c5] e5
                    ld        hl,$d1a5                      ;[a8c6] 21 a5 d1
                    push      hl                            ;[a8c9] e5
                    ld        hl,$0005                      ;[a8ca] 21 05 00
                    add       hl,sp                         ;[a8cd] 39
                    ld        l,(hl)                        ;[a8ce] 6e
                    ld        h,$00                         ;[a8cf] 26 00
                    add       hl,hl                         ;[a8d1] 29
                    pop       de                            ;[a8d2] d1
                    add       hl,de                         ;[a8d3] 19
                    call      l_gint                        ;[a8d4] cd 69 a0
                    pop       de                            ;[a8d7] d1
                    call      l_uge                         ;[a8d8] cd 9f a0
                    jp        nc,i_7_include_stdio_c        ;[a8db] d2 09 a9
                    ld        hl,$0004                      ;[a8de] 21 04 00
                    add       hl,sp                         ;[a8e1] 39
                    push      hl                            ;[a8e2] e5
                    ld        e,(hl)                        ;[a8e3] 5e
                    inc       hl                            ;[a8e4] 23
                    ld        d,(hl)                        ;[a8e5] 56
                    push      de                            ;[a8e6] d5
                    ld        hl,$d1a5                      ;[a8e7] 21 a5 d1
                    push      hl                            ;[a8ea] e5
                    ld        hl,$0007                      ;[a8eb] 21 07 00
                    add       hl,sp                         ;[a8ee] 39
                    ld        l,(hl)                        ;[a8ef] 6e
                    ld        h,$00                         ;[a8f0] 26 00
                    add       hl,hl                         ;[a8f2] 29
                    pop       de                            ;[a8f3] d1
                    add       hl,de                         ;[a8f4] 19
                    call      l_gint                        ;[a8f5] cd 69 a0
                    pop       de                            ;[a8f8] d1
                    ex        de,hl                         ;[a8f9] eb
                    and       a                             ;[a8fa] a7
                    sbc       hl,de                         ;[a8fb] ed 52
                    pop       de                            ;[a8fd] d1
                    call      l_pint                        ;[a8fe] cd 95 a0
                    ld        hl,$0000                      ;[a901] 21 00 00
                    add       hl,sp                         ;[a904] 39
                    inc       (hl)                          ;[a905] 34
                    jp        i_6_include_stdio_c           ;[a906] c3 c2 a8
i_7_include_stdio_c:
                    pop       hl                            ;[a909] e1
                    push      hl                            ;[a90a] e5
                    ld        h,$00                         ;[a90b] 26 00
                    xor       a                             ;[a90d] af
                    sub       l                             ;[a90e] 95
                    jp        c,i_9_include_stdio_c         ;[a90f] da 23 a9
                    pop       bc                            ;[a912] c1
                    pop       hl                            ;[a913] e1
                    push      hl                            ;[a914] e5
                    push      bc                            ;[a915] c5
                    ld        a,h                           ;[a916] 7c
                    or        l                             ;[a917] b5
                    jp        nz,i_9_include_stdio_c        ;[a918] c2 23 a9
                    inc       hl                            ;[a91b] 23
                    add       hl,sp                         ;[a91c] 39
                    ld        a,(hl)                        ;[a91d] 7e
                    cp        $04                           ;[a91e] fe 04
                    jp        nz,i_8_include_stdio_c        ;[a920] c2 41 a9
i_9_include_stdio_c:
                    pop       hl                            ;[a923] e1
                    push      hl                            ;[a924] e5
                    ld        bc,$0030                      ;[a925] 01 30 00
                    add       hl,bc                         ;[a928] 09
                    ld        h,$00                         ;[a929] 26 00
                    dec       sp                            ;[a92b] 3b
                    ld        a,l                           ;[a92c] 7d
                    pop       hl                            ;[a92d] e1
                    ld        l,a                           ;[a92e] 6f
                    push      hl                            ;[a92f] e5
                    ld        h,$00                         ;[a930] 26 00
                    call      _putchar                      ;[a932] cd 75 a8
                    ld        hl,$0003                      ;[a935] 21 03 00
                    add       hl,sp                         ;[a938] 39
                    ld        de,$0001                      ;[a939] 11 01 00
                    ld        (hl),e                        ;[a93c] 73
                    inc       hl                            ;[a93d] 23
                    ld        (hl),d                        ;[a93e] 72
                    ex        de,hl                         ;[a93f] eb
                    inc       sp                            ;[a940] 33
i_8_include_stdio_c:
                    inc       sp                            ;[a941] 33
                    jp        i_3_include_stdio_c           ;[a942] c3 b0 a8
i_4_include_stdio_c:
                    inc       sp                            ;[a945] 33
                    pop       bc                            ;[a946] c1
                    pop       bc                            ;[a947] c1
                    ret                                     ;[a948] c9

_puth:
                    push      hl                            ;[a949] e5
                    dec       sp                            ;[a94a] 3b
                    pop       hl                            ;[a94b] e1
                    ld        l,$00                         ;[a94c] 2e 00
                    push      hl                            ;[a94e] e5
                    ld        hl,$000c                      ;[a94f] 21 0c 00
                    push      hl                            ;[a952] e5
                    jp        i_13_include_stdio_c          ;[a953] c3 5c a9
i_11_include_stdio_c:
                    pop       hl                            ;[a956] e1
                    ld        bc,$fffc                      ;[a957] 01 fc ff
                    add       hl,bc                         ;[a95a] 09
                    push      hl                            ;[a95b] e5
i_13_include_stdio_c:
                    pop       hl                            ;[a95c] e1
                    push      hl                            ;[a95d] e5
                    ld        a,h                           ;[a95e] 7c
                    rla                                     ;[a95f] 17
                    ccf                                     ;[a960] 3f
                    jp        nc,i_12_include_stdio_c       ;[a961] d2 ca a9
                    ld        hl,$0003                      ;[a964] 21 03 00
                    call      l_gintspsp                    ;[a967] cd 5d a0
                    pop       bc                            ;[a96a] c1
                    pop       hl                            ;[a96b] e1
                    push      hl                            ;[a96c] e5
                    push      bc                            ;[a96d] c5
                    pop       de                            ;[a96e] d1
                    call      l_asr_u                       ;[a96f] cd 36 a0
                    ld        a,l                           ;[a972] 7d
                    and       $0f                           ;[a973] e6 0f
                    ld        l,a                           ;[a975] 6f
                    ld        h,$00                         ;[a976] 26 00
                    dec       sp                            ;[a978] 3b
                    ld        a,l                           ;[a979] 7d
                    pop       hl                            ;[a97a] e1
                    ld        l,a                           ;[a97b] 6f
                    push      hl                            ;[a97c] e5
                    ld        h,$00                         ;[a97d] 26 00
                    xor       a                             ;[a97f] af
                    sub       l                             ;[a980] 95
                    jp        c,i_15_include_stdio_c        ;[a981] da 95 a9
                    ld        hl,$0003                      ;[a984] 21 03 00
                    add       hl,sp                         ;[a987] 39
                    ld        a,(hl)                        ;[a988] 7e
                    and       a                             ;[a989] a7
                    jp        nz,i_15_include_stdio_c       ;[a98a] c2 95 a9
                    call      l_gint1sp                     ;[a98d] cd 6e a0
                    ld        a,h                           ;[a990] 7c
                    or        l                             ;[a991] b5
                    jp        nz,i_14_include_stdio_c       ;[a992] c2 c6 a9
i_15_include_stdio_c:
                    pop       hl                            ;[a995] e1
                    push      hl                            ;[a996] e5
                    ld        a,l                           ;[a997] 7d
                    sub       $0a                           ;[a998] d6 0a
                    jp        nc,i_17_include_stdio_c       ;[a99a] d2 a8 a9
                    pop       hl                            ;[a99d] e1
                    push      hl                            ;[a99e] e5
                    ld        h,$00                         ;[a99f] 26 00
                    ld        bc,$0030                      ;[a9a1] 01 30 00
                    add       hl,bc                         ;[a9a4] 09
                    jp        i_18_include_stdio_c          ;[a9a5] c3 b0 a9
i_17_include_stdio_c:
                    pop       hl                            ;[a9a8] e1
                    push      hl                            ;[a9a9] e5
                    ld        h,$00                         ;[a9aa] 26 00
                    ld        bc,$0037                      ;[a9ac] 01 37 00
                    add       hl,bc                         ;[a9af] 09
i_18_include_stdio_c:
                    ld        h,$00                         ;[a9b0] 26 00
                    dec       sp                            ;[a9b2] 3b
                    ld        a,l                           ;[a9b3] 7d
                    pop       hl                            ;[a9b4] e1
                    ld        l,a                           ;[a9b5] 6f
                    push      hl                            ;[a9b6] e5
                    ld        h,$00                         ;[a9b7] 26 00
                    call      _putchar                      ;[a9b9] cd 75 a8
                    ld        hl,$0004                      ;[a9bc] 21 04 00
                    add       hl,sp                         ;[a9bf] 39
                    ld        (hl),$01                      ;[a9c0] 36 01
                    ld        l,(hl)                        ;[a9c2] 6e
                    ld        h,$00                         ;[a9c3] 26 00
                    inc       sp                            ;[a9c5] 33
i_14_include_stdio_c:
                    inc       sp                            ;[a9c6] 33
                    jp        i_11_include_stdio_c          ;[a9c7] c3 56 a9
i_12_include_stdio_c:
                    pop       bc                            ;[a9ca] c1
                    inc       sp                            ;[a9cb] 33
                    pop       bc                            ;[a9cc] c1
                    ret                                     ;[a9cd] c9

_mfs_init:
                    ld        hl,(_fs_ptr)                  ;[a9ce] 2a b5 d1
                    push      hl                            ;[a9d1] e5
                    ld        (hl),$00                      ;[a9d2] 36 00
                    ld        d,h                           ;[a9d4] 54
                    ld        e,l                           ;[a9d5] 5d
                    inc       de                            ;[a9d6] 13
                    ld        bc,$0ffe                      ;[a9d7] 01 fe 0f
                    ldir                                    ;[a9da] ed b0
                    pop       hl                            ;[a9dc] e1
                    ld        hl,(_filecount)               ;[a9dd] 2a b1 d1
                    ld        de,$0000                      ;[a9e0] 11 00 00
                    ld        (hl),e                        ;[a9e3] 73
                    inc       hl                            ;[a9e4] 23
                    ld        (hl),d                        ;[a9e5] 72
                    ex        de,hl                         ;[a9e6] eb
                    ret                                     ;[a9e7] c9

_find_free_block:
                    dec       sp                            ;[a9e8] 3b
                    pop       hl                            ;[a9e9] e1
                    ld        l,$00                         ;[a9ea] 2e 00
                    push      hl                            ;[a9ec] e5
                    jp        i_8_sys_fs_mfs_c              ;[a9ed] c3 f5 a9
i_9_sys_fs_mfs_c:
                    ld        hl,$0000                      ;[a9f0] 21 00 00
                    add       hl,sp                         ;[a9f3] 39
                    inc       (hl)                          ;[a9f4] 34
i_8_sys_fs_mfs_c:
                    pop       hl                            ;[a9f5] e1
                    push      hl                            ;[a9f6] e5
                    ld        a,l                           ;[a9f7] 7d
                    sub       $ff                           ;[a9f8] d6 ff
                    jp        nc,i_7_sys_fs_mfs_c           ;[a9fa] d2 18 aa
                    ld        hl,$0000                      ;[a9fd] 21 00 00
                    add       hl,sp                         ;[aa00] 39
                    ld        h,(hl)                        ;[aa01] 66
                    ld        l,$00                         ;[aa02] 2e 00
                    ld        a,$f1                         ;[aa04] 3e f1
                    add       h                             ;[aa06] 84
                    ld        h,a                           ;[aa07] 67
                    ld        (_block_ptr),hl               ;[aa08] 22 b3 d1
                    call      l_gint                        ;[aa0b] cd 69 a0
                    ld        a,h                           ;[aa0e] 7c
                    or        l                             ;[aa0f] b5
                    jp        nz,i_9_sys_fs_mfs_c           ;[aa10] c2 f0 a9
                    ld        hl,(_block_ptr)               ;[aa13] 2a b3 d1
                    inc       sp                            ;[aa16] 33
                    ret                                     ;[aa17] c9

i_7_sys_fs_mfs_c:
                    inc       sp                            ;[aa18] 33
                    ld        hl,$0000                      ;[aa19] 21 00 00
                    ret                                     ;[aa1c] c9

_find_file:
                    push      hl                            ;[aa1d] e5
                    dec       sp                            ;[aa1e] 3b
                    pop       hl                            ;[aa1f] e1
                    ld        l,$00                         ;[aa20] 2e 00
                    push      hl                            ;[aa22] e5
                    jp        i_12_sys_fs_mfs_c             ;[aa23] c3 2b aa
i_13_sys_fs_mfs_c:
                    ld        hl,$0000                      ;[aa26] 21 00 00
                    add       hl,sp                         ;[aa29] 39
                    inc       (hl)                          ;[aa2a] 34
i_12_sys_fs_mfs_c:
                    pop       hl                            ;[aa2b] e1
                    push      hl                            ;[aa2c] e5
                    ld        h,$00                         ;[aa2d] 26 00
                    push      hl                            ;[aa2f] e5
                    ld        hl,(_filecount)               ;[aa30] 2a b1 d1
                    call      l_gint                        ;[aa33] cd 69 a0
                    pop       de                            ;[aa36] d1
                    ex        de,hl                         ;[aa37] eb
                    and       a                             ;[aa38] a7
                    sbc       hl,de                         ;[aa39] ed 52
                    jp        nc,i_11_sys_fs_mfs_c          ;[aa3b] d2 77 aa
                    call      l_gint1sp                     ;[aa3e] cd 6e a0
                    push      hl                            ;[aa41] e5
                    ld        hl,(_files)                   ;[aa42] 2a af d1
                    push      hl                            ;[aa45] e5
                    ld        hl,$0004                      ;[aa46] 21 04 00
                    add       hl,sp                         ;[aa49] 39
                    ld        l,(hl)                        ;[aa4a] 6e
                    ld        h,$00                         ;[aa4b] 26 00
                    add       hl,hl                         ;[aa4d] 29
                    ld        b,h                           ;[aa4e] 44
                    ld        c,l                           ;[aa4f] 4d
                    add       hl,bc                         ;[aa50] 09
                    add       hl,bc                         ;[aa51] 09
                    add       hl,hl                         ;[aa52] 29
                    add       hl,bc                         ;[aa53] 09
                    pop       de                            ;[aa54] d1
                    add       hl,de                         ;[aa55] 19
                    inc       hl                            ;[aa56] 23
                    push      hl                            ;[aa57] e5
                    call      ___strcmp_callee              ;[aa58] cd fd b0
                    ld        a,h                           ;[aa5b] 7c
                    or        l                             ;[aa5c] b5
                    jp        nz,i_13_sys_fs_mfs_c          ;[aa5d] c2 26 aa
                    ld        hl,(_files)                   ;[aa60] 2a af d1
                    push      hl                            ;[aa63] e5
                    ld        hl,$0002                      ;[aa64] 21 02 00
                    add       hl,sp                         ;[aa67] 39
                    ld        l,(hl)                        ;[aa68] 6e
                    ld        h,$00                         ;[aa69] 26 00
                    add       hl,hl                         ;[aa6b] 29
                    ld        b,h                           ;[aa6c] 44
                    ld        c,l                           ;[aa6d] 4d
                    add       hl,bc                         ;[aa6e] 09
                    add       hl,bc                         ;[aa6f] 09
                    add       hl,hl                         ;[aa70] 29
                    add       hl,bc                         ;[aa71] 09
                    pop       de                            ;[aa72] d1
                    add       hl,de                         ;[aa73] 19
                    inc       sp                            ;[aa74] 33
                    pop       bc                            ;[aa75] c1
                    ret                                     ;[aa76] c9

i_11_sys_fs_mfs_c:
                    inc       sp                            ;[aa77] 33
                    ld        hl,$0000                      ;[aa78] 21 00 00
                    pop       bc                            ;[aa7b] c1
                    ret                                     ;[aa7c] c9

_get_file_blockptr:
                    push      hl                            ;[aa7d] e5
                    dec       sp                            ;[aa7e] 3b
                    pop       hl                            ;[aa7f] e1
                    ld        l,$00                         ;[aa80] 2e 00
                    push      hl                            ;[aa82] e5
                    jp        i_16_sys_fs_mfs_c             ;[aa83] c3 8b aa
i_17_sys_fs_mfs_c:
                    ld        hl,$0000                      ;[aa86] 21 00 00
                    add       hl,sp                         ;[aa89] 39
                    inc       (hl)                          ;[aa8a] 34
i_16_sys_fs_mfs_c:
                    pop       hl                            ;[aa8b] e1
                    push      hl                            ;[aa8c] e5
                    ld        h,$00                         ;[aa8d] 26 00
                    push      hl                            ;[aa8f] e5
                    ld        hl,(_filecount)               ;[aa90] 2a b1 d1
                    call      l_gint                        ;[aa93] cd 69 a0
                    pop       de                            ;[aa96] d1
                    ex        de,hl                         ;[aa97] eb
                    and       a                             ;[aa98] a7
                    sbc       hl,de                         ;[aa99] ed 52
                    jp        nc,i_15_sys_fs_mfs_c          ;[aa9b] d2 de aa
                    call      l_gint1sp                     ;[aa9e] cd 6e a0
                    push      hl                            ;[aaa1] e5
                    ld        hl,(_files)                   ;[aaa2] 2a af d1
                    push      hl                            ;[aaa5] e5
                    ld        hl,$0004                      ;[aaa6] 21 04 00
                    add       hl,sp                         ;[aaa9] 39
                    ld        l,(hl)                        ;[aaaa] 6e
                    ld        h,$00                         ;[aaab] 26 00
                    add       hl,hl                         ;[aaad] 29
                    ld        b,h                           ;[aaae] 44
                    ld        c,l                           ;[aaaf] 4d
                    add       hl,bc                         ;[aab0] 09
                    add       hl,bc                         ;[aab1] 09
                    add       hl,hl                         ;[aab2] 29
                    add       hl,bc                         ;[aab3] 09
                    pop       de                            ;[aab4] d1
                    add       hl,de                         ;[aab5] 19
                    inc       hl                            ;[aab6] 23
                    push      hl                            ;[aab7] e5
                    call      ___strcmp_callee              ;[aab8] cd fd b0
                    ld        a,h                           ;[aabb] 7c
                    or        l                             ;[aabc] b5
                    jp        nz,i_17_sys_fs_mfs_c          ;[aabd] c2 86 aa
                    ld        hl,(_files)                   ;[aac0] 2a af d1
                    push      hl                            ;[aac3] e5
                    ld        hl,$0002                      ;[aac4] 21 02 00
                    add       hl,sp                         ;[aac7] 39
                    ld        l,(hl)                        ;[aac8] 6e
                    ld        h,$00                         ;[aac9] 26 00
                    add       hl,hl                         ;[aacb] 29
                    ld        b,h                           ;[aacc] 44
                    ld        c,l                           ;[aacd] 4d
                    add       hl,bc                         ;[aace] 09
                    add       hl,bc                         ;[aacf] 09
                    add       hl,hl                         ;[aad0] 29
                    add       hl,bc                         ;[aad1] 09
                    pop       de                            ;[aad2] d1
                    add       hl,de                         ;[aad3] 19
                    ld        bc,$000c                      ;[aad4] 01 0c 00
                    add       hl,bc                         ;[aad7] 09
                    call      l_gint                        ;[aad8] cd 69 a0
                    inc       sp                            ;[aadb] 33
                    pop       bc                            ;[aadc] c1
                    ret                                     ;[aadd] c9

i_15_sys_fs_mfs_c:
                    inc       sp                            ;[aade] 33
                    ld        hl,$0000                      ;[aadf] 21 00 00
                    pop       bc                            ;[aae2] c1
                    ret                                     ;[aae3] c9

_read_file:
                    call      l_gint6sp                     ;[aae4] cd 80 a0
                    call      _find_file                    ;[aae7] cd 1d aa
                    ld        (_tempfile),hl                ;[aaea] 22 d7 d0
                    ld        de,$0000                      ;[aaed] 11 00 00
                    call      l_eq                          ;[aaf0] cd 40 a0
                    jp        nc,i_18_sys_fs_mfs_c          ;[aaf3] d2 fa aa
                    ld        hl,$00ff                      ;[aaf6] 21 ff 00
                    ret                                     ;[aaf9] c9

i_18_sys_fs_mfs_c:
                    call      l_gint4sp                     ;[aafa] cd 77 a0
                    ld        (_remaining),hl               ;[aafd] 22 d9 d0
                    ld        hl,(_tempfile)                ;[ab00] 2a d7 d0
                    ld        bc,$000c                      ;[ab03] 01 0c 00
                    add       hl,bc                         ;[ab06] 09
                    call      l_gint                        ;[ab07] cd 69 a0
                    ld        (_block),hl                   ;[ab0a] 22 db d0
i_19_sys_fs_mfs_c:
                    ld        hl,(_remaining)               ;[ab0d] 2a d9 d0
                    ld        a,h                           ;[ab10] 7c
                    or        l                             ;[ab11] b5
                    jp        z,i_21_sys_fs_mfs_c           ;[ab12] ca 9a ab
                    ld        hl,(_block)                   ;[ab15] 2a db d0
                    push      hl                            ;[ab18] e5
                    pop       hl                            ;[ab19] e1
                    ld        a,h                           ;[ab1a] 7c
                    or        l                             ;[ab1b] b5
                    jp        z,i_21_sys_fs_mfs_c           ;[ab1c] ca 9a ab
i_22_i_21:
                    ld        hl,(_remaining)               ;[ab1f] 2a d9 d0
                    ld        de,$00fc                      ;[ab22] 11 fc 00
                    ex        de,hl                         ;[ab25] eb
                    and       a                             ;[ab26] a7
                    sbc       hl,de                         ;[ab27] ed 52
                    jp        nc,i_23_sys_fs_mfs_c          ;[ab29] d2 32 ab
                    ld        hl,$00fc                      ;[ab2c] 21 fc 00
                    jp        i_24                          ;[ab2f] c3 35 ab
i_23_sys_fs_mfs_c:
                    ld        hl,(_remaining)               ;[ab32] 2a d9 d0
i_24:
                    ld        (_bytes_in_block),hl          ;[ab35] 22 dd d0
                    ld        hl,$0000                      ;[ab38] 21 00 00
                    push      hl                            ;[ab3b] e5
                    jp        i_27_sys_fs_mfs_c             ;[ab3c] c3 42 ab
i_25_sys_fs_mfs_c:
                    pop       hl                            ;[ab3f] e1
                    inc       hl                            ;[ab40] 23
                    push      hl                            ;[ab41] e5
i_27_sys_fs_mfs_c:
                    pop       de                            ;[ab42] d1
                    push      de                            ;[ab43] d5
                    ld        hl,(_bytes_in_block)          ;[ab44] 2a dd d0
                    ex        de,hl                         ;[ab47] eb
                    and       a                             ;[ab48] a7
                    sbc       hl,de                         ;[ab49] ed 52
                    jp        nc,i_26_sys_fs_mfs_c          ;[ab4b] d2 72 ab
                    ld        hl,$0004                      ;[ab4e] 21 04 00
                    call      l_gintspsp                    ;[ab51] cd 5d a0
                    pop       bc                            ;[ab54] c1
                    pop       hl                            ;[ab55] e1
                    push      hl                            ;[ab56] e5
                    push      bc                            ;[ab57] c5
                    pop       de                            ;[ab58] d1
                    add       hl,de                         ;[ab59] 19
                    push      hl                            ;[ab5a] e5
                    ld        hl,(_block)                   ;[ab5b] 2a db d0
                    push      hl                            ;[ab5e] e5
                    call      l_gint4sp                     ;[ab5f] cd 77 a0
                    ld        bc,$0004                      ;[ab62] 01 04 00
                    add       hl,bc                         ;[ab65] 09
                    add       hl,hl                         ;[ab66] 29
                    pop       de                            ;[ab67] d1
                    add       hl,de                         ;[ab68] 19
                    call      l_gint                        ;[ab69] cd 69 a0
                    pop       de                            ;[ab6c] d1
                    ld        a,l                           ;[ab6d] 7d
                    ld        (de),a                        ;[ab6e] 12
                    jp        i_25_sys_fs_mfs_c             ;[ab6f] c3 3f ab
i_26_sys_fs_mfs_c:
                    pop       bc                            ;[ab72] c1
                    pop       bc                            ;[ab73] c1
                    pop       hl                            ;[ab74] e1
                    push      hl                            ;[ab75] e5
                    push      bc                            ;[ab76] c5
                    ex        de,hl                         ;[ab77] eb
                    ld        hl,(_bytes_in_block)          ;[ab78] 2a dd d0
                    add       hl,de                         ;[ab7b] 19
                    pop       de                            ;[ab7c] d1
                    pop       bc                            ;[ab7d] c1
                    push      hl                            ;[ab7e] e5
                    push      de                            ;[ab7f] d5
                    ld        de,(_remaining)               ;[ab80] ed 5b d9 d0
                    ld        hl,(_bytes_in_block)          ;[ab84] 2a dd d0
                    ex        de,hl                         ;[ab87] eb
                    and       a                             ;[ab88] a7
                    sbc       hl,de                         ;[ab89] ed 52
                    ld        (_remaining),hl               ;[ab8b] 22 d9 d0
                    ld        hl,(_block)                   ;[ab8e] 2a db d0
                    call      l_gint2                       ;[ab91] cd 67 a0
                    ld        (_block),hl                   ;[ab94] 22 db d0
                    jp        i_19_sys_fs_mfs_c             ;[ab97] c3 0d ab
i_21_sys_fs_mfs_c:
                    ld        hl,$0000                      ;[ab9a] 21 00 00
                    ret                                     ;[ab9d] c9

_write_file:
                    call      l_gint6sp                     ;[ab9e] cd 80 a0
                    call      _find_file                    ;[aba1] cd 1d aa
                    ld        (_tempfile),hl                ;[aba4] 22 d7 d0
                    ld        de,$0000                      ;[aba7] 11 00 00
                    call      l_eq                          ;[abaa] cd 40 a0
                    jp        nc,i_28_sys_fs_mfs_c          ;[abad] d2 b4 ab
                    ld        hl,$00ff                      ;[abb0] 21 ff 00
                    ret                                     ;[abb3] c9

i_28_sys_fs_mfs_c:
                    call      l_gint4sp                     ;[abb4] cd 77 a0
                    ld        (_remaining),hl               ;[abb7] 22 d9 d0
                    ld        hl,(_tempfile)                ;[abba] 2a d7 d0
                    ld        bc,$000c                      ;[abbd] 01 0c 00
                    add       hl,bc                         ;[abc0] 09
                    call      l_gint                        ;[abc1] cd 69 a0
                    ld        (_block),hl                   ;[abc4] 22 db d0
                    ld        hl,(_tempfile)                ;[abc7] 2a d7 d0
                    ld        bc,$0009                      ;[abca] 01 09 00
                    add       hl,bc                         ;[abcd] 09
                    ex        de,hl                         ;[abce] eb
                    call      l_gint4sp                     ;[abcf] cd 77 a0
                    call      l_pint                        ;[abd2] cd 95 a0
                    ld        hl,(_tempfile)                ;[abd5] 2a d7 d0
                    ld        bc,$000b                      ;[abd8] 01 0b 00
                    add       hl,bc                         ;[abdb] 09
                    ld        (hl),$00                      ;[abdc] 36 00
i_29_sys_fs_mfs_c:
                    ld        hl,(_remaining)               ;[abde] 2a d9 d0
                    ld        a,h                           ;[abe1] 7c
                    or        l                             ;[abe2] b5
                    jp        z,i_30_sys_fs_mfs_c           ;[abe3] ca 9a ac
                    ld        hl,(_tempfile)                ;[abe6] 2a d7 d0
                    ld        bc,$000b                      ;[abe9] 01 0b 00
                    add       hl,bc                         ;[abec] 09
                    inc       (hl)                          ;[abed] 34
                    ld        hl,(_remaining)               ;[abee] 2a d9 d0
                    ld        de,$00fc                      ;[abf1] 11 fc 00
                    ex        de,hl                         ;[abf4] eb
                    and       a                             ;[abf5] a7
                    sbc       hl,de                         ;[abf6] ed 52
                    jp        nc,i_31_sys_fs_mfs_c          ;[abf8] d2 01 ac
                    ld        hl,$00fc                      ;[abfb] 21 fc 00
                    jp        i_32_sys_fs_mfs_c             ;[abfe] c3 04 ac
i_31_sys_fs_mfs_c:
                    ld        hl,(_remaining)               ;[ac01] 2a d9 d0
i_32_sys_fs_mfs_c:
                    ld        (_bytes_in_block),hl          ;[ac04] 22 dd d0
                    ld        hl,$0000                      ;[ac07] 21 00 00
                    push      hl                            ;[ac0a] e5
                    jp        i_35_sys_fs_mfs_c             ;[ac0b] c3 11 ac
i_33_sys_fs_mfs_c:
                    pop       hl                            ;[ac0e] e1
                    inc       hl                            ;[ac0f] 23
                    push      hl                            ;[ac10] e5
i_35_sys_fs_mfs_c:
                    pop       de                            ;[ac11] d1
                    push      de                            ;[ac12] d5
                    ld        hl,(_bytes_in_block)          ;[ac13] 2a dd d0
                    ex        de,hl                         ;[ac16] eb
                    and       a                             ;[ac17] a7
                    sbc       hl,de                         ;[ac18] ed 52
                    jp        nc,i_34_sys_fs_mfs_c          ;[ac1a] d2 41 ac
                    pop       hl                            ;[ac1d] e1
                    push      hl                            ;[ac1e] e5
                    ld        de,(_block)                   ;[ac1f] ed 5b db d0
                    push      de                            ;[ac23] d5
                    ld        bc,$0004                      ;[ac24] 01 04 00
                    add       hl,bc                         ;[ac27] 09
                    add       hl,hl                         ;[ac28] 29
                    pop       de                            ;[ac29] d1
                    add       hl,de                         ;[ac2a] 19
                    push      hl                            ;[ac2b] e5
                    ld        hl,$0006                      ;[ac2c] 21 06 00
                    call      l_gintspsp                    ;[ac2f] cd 5d a0
                    call      l_gint4sp                     ;[ac32] cd 77 a0
                    pop       de                            ;[ac35] d1
                    add       hl,de                         ;[ac36] 19
                    ld        l,(hl)                        ;[ac37] 6e
                    ld        h,$00                         ;[ac38] 26 00
                    pop       de                            ;[ac3a] d1
                    call      l_pint                        ;[ac3b] cd 95 a0
                    jp        i_33_sys_fs_mfs_c             ;[ac3e] c3 0e ac
i_34_sys_fs_mfs_c:
                    pop       bc                            ;[ac41] c1
                    pop       bc                            ;[ac42] c1
                    pop       hl                            ;[ac43] e1
                    push      hl                            ;[ac44] e5
                    push      bc                            ;[ac45] c5
                    ex        de,hl                         ;[ac46] eb
                    ld        hl,(_bytes_in_block)          ;[ac47] 2a dd d0
                    add       hl,de                         ;[ac4a] 19
                    pop       de                            ;[ac4b] d1
                    pop       bc                            ;[ac4c] c1
                    push      hl                            ;[ac4d] e5
                    push      de                            ;[ac4e] d5
                    ld        de,(_remaining)               ;[ac4f] ed 5b d9 d0
                    ld        hl,(_bytes_in_block)          ;[ac53] 2a dd d0
                    ex        de,hl                         ;[ac56] eb
                    and       a                             ;[ac57] a7
                    sbc       hl,de                         ;[ac58] ed 52
                    ld        (_remaining),hl               ;[ac5a] 22 d9 d0
                    ld        a,h                           ;[ac5d] 7c
                    rlca                                    ;[ac5e] 07
                    jr        c,$ac65                       ;[ac5f] 38 04
                    or        l                             ;[ac61] b5
                    jr        nz,$ac65                      ;[ac62] 20 01
                    scf                                     ;[ac64] 37
                    jp        nc,i_36                       ;[ac65] d2 74 ac
                    ld        hl,(_block)                   ;[ac68] 2a db d0
                    inc       hl                            ;[ac6b] 23
                    inc       hl                            ;[ac6c] 23
                    xor       a                             ;[ac6d] af
                    ld        (hl),a                        ;[ac6e] 77
                    inc       hl                            ;[ac6f] 23
                    ld        (hl),a                        ;[ac70] 77
                    jp        i_30_sys_fs_mfs_c             ;[ac71] c3 9a ac
i_36:
                    call      _find_free_block              ;[ac74] cd e8 a9
                    push      hl                            ;[ac77] e5
                    ld        de,$0000                      ;[ac78] 11 00 00
                    call      l_eq                          ;[ac7b] cd 40 a0
                    jp        nc,i_37                       ;[ac7e] d2 86 ac
                    ld        hl,$00ff                      ;[ac81] 21 ff 00
                    pop       bc                            ;[ac84] c1
                    ret                                     ;[ac85] c9

i_37:
                    ld        hl,(_block)                   ;[ac86] 2a db d0
                    inc       hl                            ;[ac89] 23
                    inc       hl                            ;[ac8a] 23
                    pop       de                            ;[ac8b] d1
                    push      de                            ;[ac8c] d5
                    ld        (hl),e                        ;[ac8d] 73
                    inc       hl                            ;[ac8e] 23
                    ld        (hl),d                        ;[ac8f] 72
                    ex        de,hl                         ;[ac90] eb
                    pop       hl                            ;[ac91] e1
                    push      hl                            ;[ac92] e5
                    ld        (_block),hl                   ;[ac93] 22 db d0
                    pop       bc                            ;[ac96] c1
                    jp        i_29_sys_fs_mfs_c             ;[ac97] c3 de ab
i_30_sys_fs_mfs_c:
                    ld        hl,$0000                      ;[ac9a] 21 00 00
                    ret                                     ;[ac9d] c9

_create_file:
                    push      hl                            ;[ac9e] e5
                    call      _find_free_block              ;[ac9f] cd e8 a9
                    push      hl                            ;[aca2] e5
                    ld        de,$0000                      ;[aca3] 11 00 00
                    call      l_eq                          ;[aca6] cd 40 a0
                    jp        c,i_39                        ;[aca9] da c8 ac
                    ld        hl,(_filecount)               ;[acac] 2a b1 d1
                    ld        e,(hl)                        ;[acaf] 5e
                    inc       hl                            ;[acb0] 23
                    ld        d,(hl)                        ;[acb1] 56
                    ld        hl,$0008                      ;[acb2] 21 08 00
                    call      l_uge                         ;[acb5] cd 9f a0
                    jp        c,i_39                        ;[acb8] da c8 ac
                    pop       bc                            ;[acbb] c1
                    pop       hl                            ;[acbc] e1
                    push      hl                            ;[acbd] e5
                    push      bc                            ;[acbe] c5
                    call      _find_file                    ;[acbf] cd 1d aa
                    push      hl                            ;[acc2] e5
                    pop       hl                            ;[acc3] e1
                    ld        a,h                           ;[acc4] 7c
                    or        l                             ;[acc5] b5
                    jr        z,i_40                        ;[acc6] 28 03
i_39:
                    ld        hl,$0001                      ;[acc8] 21 01 00
i_40:
                    ld        a,h                           ;[accb] 7c
                    or        l                             ;[accc] b5
                    jp        z,i_38                        ;[accd] ca d6 ac
                    ld        hl,$00ff                      ;[acd0] 21 ff 00
                    pop       bc                            ;[acd3] c1
                    pop       bc                            ;[acd4] c1
                    ret                                     ;[acd5] c9

i_38:
                    ld        hl,(_files)                   ;[acd6] 2a af d1
                    push      hl                            ;[acd9] e5
                    ld        hl,(_filecount)               ;[acda] 2a b1 d1
                    call      l_gint                        ;[acdd] cd 69 a0
                    add       hl,hl                         ;[ace0] 29
                    ld        b,h                           ;[ace1] 44
                    ld        c,l                           ;[ace2] 4d
                    add       hl,bc                         ;[ace3] 09
                    add       hl,bc                         ;[ace4] 09
                    add       hl,hl                         ;[ace5] 29
                    add       hl,bc                         ;[ace6] 09
                    pop       de                            ;[ace7] d1
                    add       hl,de                         ;[ace8] 19
                    inc       hl                            ;[ace9] 23
                    push      hl                            ;[acea] e5
                    ld        hl,$0004                      ;[aceb] 21 04 00
                    call      l_gintspsp                    ;[acee] cd 5d a0
                    ld        hl,$0008                      ;[acf1] 21 08 00
                    push      hl                            ;[acf4] e5
                    call      ___strncpy_callee             ;[acf5] cd 04 b1
                    ld        hl,(_files)                   ;[acf8] 2a af d1
                    push      hl                            ;[acfb] e5
                    ld        hl,(_filecount)               ;[acfc] 2a b1 d1
                    call      l_gint                        ;[acff] cd 69 a0
                    add       hl,hl                         ;[ad02] 29
                    ld        b,h                           ;[ad03] 44
                    ld        c,l                           ;[ad04] 4d
                    add       hl,bc                         ;[ad05] 09
                    add       hl,bc                         ;[ad06] 09
                    add       hl,hl                         ;[ad07] 29
                    add       hl,bc                         ;[ad08] 09
                    pop       de                            ;[ad09] d1
                    add       hl,de                         ;[ad0a] 19
                    ld        (hl),$01                      ;[ad0b] 36 01
                    ld        hl,(_files)                   ;[ad0d] 2a af d1
                    push      hl                            ;[ad10] e5
                    ld        hl,(_filecount)               ;[ad11] 2a b1 d1
                    call      l_gint                        ;[ad14] cd 69 a0
                    add       hl,hl                         ;[ad17] 29
                    ld        b,h                           ;[ad18] 44
                    ld        c,l                           ;[ad19] 4d
                    add       hl,bc                         ;[ad1a] 09
                    add       hl,bc                         ;[ad1b] 09
                    add       hl,hl                         ;[ad1c] 29
                    add       hl,bc                         ;[ad1d] 09
                    pop       de                            ;[ad1e] d1
                    add       hl,de                         ;[ad1f] 19
                    ld        bc,$0009                      ;[ad20] 01 09 00
                    add       hl,bc                         ;[ad23] 09
                    xor       a                             ;[ad24] af
                    ld        (hl),a                        ;[ad25] 77
                    inc       hl                            ;[ad26] 23
                    ld        (hl),a                        ;[ad27] 77
                    ld        hl,(_files)                   ;[ad28] 2a af d1
                    push      hl                            ;[ad2b] e5
                    ld        hl,(_filecount)               ;[ad2c] 2a b1 d1
                    call      l_gint                        ;[ad2f] cd 69 a0
                    add       hl,hl                         ;[ad32] 29
                    ld        b,h                           ;[ad33] 44
                    ld        c,l                           ;[ad34] 4d
                    add       hl,bc                         ;[ad35] 09
                    add       hl,bc                         ;[ad36] 09
                    add       hl,hl                         ;[ad37] 29
                    add       hl,bc                         ;[ad38] 09
                    pop       de                            ;[ad39] d1
                    add       hl,de                         ;[ad3a] 19
                    ld        bc,$000b                      ;[ad3b] 01 0b 00
                    add       hl,bc                         ;[ad3e] 09
                    ld        (hl),$01                      ;[ad3f] 36 01
                    ld        hl,(_files)                   ;[ad41] 2a af d1
                    push      hl                            ;[ad44] e5
                    ld        hl,(_filecount)               ;[ad45] 2a b1 d1
                    call      l_gint                        ;[ad48] cd 69 a0
                    add       hl,hl                         ;[ad4b] 29
                    ld        b,h                           ;[ad4c] 44
                    ld        c,l                           ;[ad4d] 4d
                    add       hl,bc                         ;[ad4e] 09
                    add       hl,bc                         ;[ad4f] 09
                    add       hl,hl                         ;[ad50] 29
                    add       hl,bc                         ;[ad51] 09
                    pop       de                            ;[ad52] d1
                    add       hl,de                         ;[ad53] 19
                    ld        bc,$000c                      ;[ad54] 01 0c 00
                    add       hl,bc                         ;[ad57] 09
                    pop       de                            ;[ad58] d1
                    push      de                            ;[ad59] d5
                    ld        (hl),e                        ;[ad5a] 73
                    inc       hl                            ;[ad5b] 23
                    ld        (hl),d                        ;[ad5c] 72
                    ex        de,hl                         ;[ad5d] eb
                    pop       de                            ;[ad5e] d1
                    push      de                            ;[ad5f] d5
                    ld        hl,$0001                      ;[ad60] 21 01 00
                    call      l_pint                        ;[ad63] cd 95 a0
                    pop       hl                            ;[ad66] e1
                    push      hl                            ;[ad67] e5
                    inc       hl                            ;[ad68] 23
                    inc       hl                            ;[ad69] 23
                    xor       a                             ;[ad6a] af
                    ld        (hl),a                        ;[ad6b] 77
                    inc       hl                            ;[ad6c] 23
                    ld        (hl),a                        ;[ad6d] 77
                    pop       hl                            ;[ad6e] e1
                    push      hl                            ;[ad6f] e5
                    ld        bc,$0004                      ;[ad70] 01 04 00
                    add       hl,bc                         ;[ad73] 09
                    xor       a                             ;[ad74] af
                    ld        (hl),a                        ;[ad75] 77
                    inc       hl                            ;[ad76] 23
                    ld        (hl),a                        ;[ad77] 77
                    ld        hl,(_filecount)               ;[ad78] 2a b1 d1
                    inc       (hl)                          ;[ad7b] 34
                    ld        a,(hl)                        ;[ad7c] 7e
                    inc       hl                            ;[ad7d] 23
                    jr        nz,$ad81                      ;[ad7e] 20 01
                    inc       (hl)                          ;[ad80] 34
                    ld        hl,$0000                      ;[ad81] 21 00 00
                    pop       bc                            ;[ad84] c1
                    pop       bc                            ;[ad85] c1
                    ret                                     ;[ad86] c9

_list_files:
                    dec       sp                            ;[ad87] 3b
                    pop       hl                            ;[ad88] e1
                    ld        l,$00                         ;[ad89] 2e 00
                    push      hl                            ;[ad8b] e5
                    jp        i_43                          ;[ad8c] c3 94 ad
i_41:
                    ld        hl,$0000                      ;[ad8f] 21 00 00
                    add       hl,sp                         ;[ad92] 39
                    inc       (hl)                          ;[ad93] 34
i_43:
                    pop       hl                            ;[ad94] e1
                    push      hl                            ;[ad95] e5
                    ld        h,$00                         ;[ad96] 26 00
                    push      hl                            ;[ad98] e5
                    ld        hl,(_filecount)               ;[ad99] 2a b1 d1
                    call      l_gint                        ;[ad9c] cd 69 a0
                    pop       de                            ;[ad9f] d1
                    ex        de,hl                         ;[ada0] eb
                    and       a                             ;[ada1] a7
                    sbc       hl,de                         ;[ada2] ed 52
                    jp        nc,i_42                       ;[ada4] d2 c8 ad
                    ld        hl,(_files)                   ;[ada7] 2a af d1
                    push      hl                            ;[adaa] e5
                    ld        hl,$0002                      ;[adab] 21 02 00
                    add       hl,sp                         ;[adae] 39
                    ld        l,(hl)                        ;[adaf] 6e
                    ld        h,$00                         ;[adb0] 26 00
                    add       hl,hl                         ;[adb2] 29
                    ld        b,h                           ;[adb3] 44
                    ld        c,l                           ;[adb4] 4d
                    add       hl,bc                         ;[adb5] 09
                    add       hl,bc                         ;[adb6] 09
                    add       hl,hl                         ;[adb7] 29
                    add       hl,bc                         ;[adb8] 09
                    pop       de                            ;[adb9] d1
                    add       hl,de                         ;[adba] 19
                    inc       hl                            ;[adbb] 23
                    call      _puts                         ;[adbc] cd 7f a8
                    ld        hl,$0020                      ;[adbf] 21 20 00
                    call      _putchar                      ;[adc2] cd 75 a8
                    jp        i_41                          ;[adc5] c3 8f ad
i_42:
                    inc       sp                            ;[adc8] 33
                    ret                                     ;[adc9] c9

_get_file_size:
                    push      hl                            ;[adca] e5
                    call      _find_file                    ;[adcb] cd 1d aa
                    ld        (_tempfile),hl                ;[adce] 22 d7 d0
                    ld        de,$0000                      ;[add1] 11 00 00
                    call      l_eq                          ;[add4] cd 40 a0
                    jp        nc,i_44                       ;[add7] d2 df ad
                    ld        hl,$00ff                      ;[adda] 21 ff 00
                    pop       bc                            ;[addd] c1
                    ret                                     ;[adde] c9

i_44:
                    ld        hl,(_tempfile)                ;[addf] 2a d7 d0
                    ld        bc,$0009                      ;[ade2] 01 09 00
                    add       hl,bc                         ;[ade5] 09
                    call      l_gint                        ;[ade6] cd 69 a0
                    pop       bc                            ;[ade9] c1
                    ret                                     ;[adea] c9

_devfs_init:
                    ld        hl,(_devfs_count)             ;[adeb] 2a b9 d1
                    ld        (hl),$03                      ;[adee] 36 03
                    ld        hl,(_devfs)                   ;[adf0] 2a b7 d1
                    push      hl                            ;[adf3] e5
                    ld        e,$00                         ;[adf4] 1e 00
                    ld        b,$50                         ;[adf6] 06 50
i_5_sys_fs_devfs_c:
                    ld        (hl),e                        ;[adf8] 73
                    inc       hl                            ;[adf9] 23
                    djnz      i_5_sys_fs_devfs_c            ;[adfa] 10 fc
                    pop       hl                            ;[adfc] e1
                    ld        de,(_devfs)                   ;[adfd] ed 5b b7 d1
                    ld        hl,$d1bb                      ;[ae01] 21 bb d1
                    ld        bc,$001e                      ;[ae04] 01 1e 00
                    ldir                                    ;[ae07] ed b0
                    ld        hl,$0000                      ;[ae09] 21 00 00
                    ret                                     ;[ae0c] c9

_devfs_open:
                    push      hl                            ;[ae0d] e5
                    dec       sp                            ;[ae0e] 3b
                    pop       hl                            ;[ae0f] e1
                    ld        l,$00                         ;[ae10] 2e 00
                    push      hl                            ;[ae12] e5
                    jp        i_8_sys_fs_devfs_c            ;[ae13] c3 1b ae
i_9_sys_fs_devfs_c:
                    ld        hl,$0000                      ;[ae16] 21 00 00
                    add       hl,sp                         ;[ae19] 39
                    inc       (hl)                          ;[ae1a] 34
i_8_sys_fs_devfs_c:
                    pop       hl                            ;[ae1b] e1
                    push      hl                            ;[ae1c] e5
                    ld        a,l                           ;[ae1d] 7d
                    sub       $08                           ;[ae1e] d6 08
                    jp        nc,i_7_sys_fs_devfs_c         ;[ae20] d2 4a ae
                    call      l_gint1sp                     ;[ae23] cd 6e a0
                    push      hl                            ;[ae26] e5
                    ld        hl,$d1bb                      ;[ae27] 21 bb d1
                    push      hl                            ;[ae2a] e5
                    ld        hl,$0004                      ;[ae2b] 21 04 00
                    add       hl,sp                         ;[ae2e] 39
                    ld        l,(hl)                        ;[ae2f] 6e
                    ld        h,$00                         ;[ae30] 26 00
                    ld        b,h                           ;[ae32] 44
                    ld        c,l                           ;[ae33] 4d
                    add       hl,hl                         ;[ae34] 29
                    add       hl,hl                         ;[ae35] 29
                    add       hl,bc                         ;[ae36] 09
                    add       hl,hl                         ;[ae37] 29
                    pop       de                            ;[ae38] d1
                    add       hl,de                         ;[ae39] 19
                    push      hl                            ;[ae3a] e5
                    call      ___strcmp_callee              ;[ae3b] cd fd b0
                    ld        a,h                           ;[ae3e] 7c
                    or        l                             ;[ae3f] b5
                    jp        nz,i_9_sys_fs_devfs_c         ;[ae40] c2 16 ae
                    add       hl,sp                         ;[ae43] 39
                    ld        l,(hl)                        ;[ae44] 6e
                    ld        h,$00                         ;[ae45] 26 00
                    inc       sp                            ;[ae47] 33
                    pop       bc                            ;[ae48] c1
                    ret                                     ;[ae49] c9

i_7_sys_fs_devfs_c:
                    inc       sp                            ;[ae4a] 33
                    ld        hl,$00ff                      ;[ae4b] 21 ff 00
                    pop       bc                            ;[ae4e] c1
                    ret                                     ;[ae4f] c9

_print_devices:
                    dec       sp                            ;[ae50] 3b
                    pop       hl                            ;[ae51] e1
                    ld        l,$00                         ;[ae52] 2e 00
                    push      hl                            ;[ae54] e5
                    jp        i_12_sys_fs_devfs_c           ;[ae55] c3 5d ae
i_10_sys_fs_devfs_c:
                    ld        hl,$0000                      ;[ae58] 21 00 00
                    add       hl,sp                         ;[ae5b] 39
                    inc       (hl)                          ;[ae5c] 34
i_12_sys_fs_devfs_c:
                    pop       hl                            ;[ae5d] e1
                    push      hl                            ;[ae5e] e5
                    ld        h,$00                         ;[ae5f] 26 00
                    push      hl                            ;[ae61] e5
                    ld        hl,(_devfs_count)             ;[ae62] 2a b9 d1
                    ld        e,(hl)                        ;[ae65] 5e
                    ld        d,$00                         ;[ae66] 16 00
                    pop       hl                            ;[ae68] e1
                    and       a                             ;[ae69] a7
                    sbc       hl,de                         ;[ae6a] ed 52
                    jp        nc,i_11_sys_fs_devfs_c        ;[ae6c] d2 8e ae
                    ld        hl,(_devfs)                   ;[ae6f] 2a b7 d1
                    push      hl                            ;[ae72] e5
                    ld        hl,$0002                      ;[ae73] 21 02 00
                    add       hl,sp                         ;[ae76] 39
                    ld        l,(hl)                        ;[ae77] 6e
                    ld        h,$00                         ;[ae78] 26 00
                    ld        b,h                           ;[ae7a] 44
                    ld        c,l                           ;[ae7b] 4d
                    add       hl,hl                         ;[ae7c] 29
                    add       hl,hl                         ;[ae7d] 29
                    add       hl,bc                         ;[ae7e] 09
                    add       hl,hl                         ;[ae7f] 29
                    pop       de                            ;[ae80] d1
                    add       hl,de                         ;[ae81] 19
                    call      _puts                         ;[ae82] cd 7f a8
                    ld        hl,$0020                      ;[ae85] 21 20 00
                    call      _putchar                      ;[ae88] cd 75 a8
                    jp        i_10_sys_fs_devfs_c           ;[ae8b] c3 58 ae
i_11_sys_fs_devfs_c:
                    inc       sp                            ;[ae8e] 33
                    ret                                     ;[ae8f] c9

_dev_tty_read:
                    ld        hl,$0000                      ;[ae90] 21 00 00
                    push      hl                            ;[ae93] e5
                    jp        i_15_sys_fs_devfs_c           ;[ae94] c3 9a ae
i_13_sys_fs_devfs_c:
                    pop       hl                            ;[ae97] e1
                    inc       hl                            ;[ae98] 23
                    push      hl                            ;[ae99] e5
i_15_sys_fs_devfs_c:
                    ld        hl,$0000                      ;[ae9a] 21 00 00
                    call      l_gintspsp                    ;[ae9d] cd 5d a0
                    call      l_gint6sp                     ;[aea0] cd 80 a0
                    pop       de                            ;[aea3] d1
                    ex        de,hl                         ;[aea4] eb
                    and       a                             ;[aea5] a7
                    sbc       hl,de                         ;[aea6] ed 52
                    jp        nc,i_14_sys_fs_devfs_c        ;[aea8] d2 c1 ae
                    ld        hl,$0006                      ;[aeab] 21 06 00
                    call      l_gintspsp                    ;[aeae] cd 5d a0
                    pop       bc                            ;[aeb1] c1
                    pop       hl                            ;[aeb2] e1
                    push      hl                            ;[aeb3] e5
                    push      bc                            ;[aeb4] c5
                    pop       de                            ;[aeb5] d1
                    add       hl,de                         ;[aeb6] 19
                    push      hl                            ;[aeb7] e5
                    call      _getchar                      ;[aeb8] cd 9c a8
                    pop       de                            ;[aebb] d1
                    ld        a,l                           ;[aebc] 7d
                    ld        (de),a                        ;[aebd] 12
                    jp        i_13_sys_fs_devfs_c           ;[aebe] c3 97 ae
i_14_sys_fs_devfs_c:
                    pop       bc                            ;[aec1] c1
                    ld        hl,$0000                      ;[aec2] 21 00 00
                    ret                                     ;[aec5] c9

_dev_tty_write:
                    ld        hl,$0000                      ;[aec6] 21 00 00
                    push      hl                            ;[aec9] e5
                    jp        i_18_sys_fs_devfs_c           ;[aeca] c3 d0 ae
i_16_sys_fs_devfs_c:
                    pop       hl                            ;[aecd] e1
                    inc       hl                            ;[aece] 23
                    push      hl                            ;[aecf] e5
i_18_sys_fs_devfs_c:
                    ld        hl,$0000                      ;[aed0] 21 00 00
                    call      l_gintspsp                    ;[aed3] cd 5d a0
                    call      l_gint6sp                     ;[aed6] cd 80 a0
                    pop       de                            ;[aed9] d1
                    ex        de,hl                         ;[aeda] eb
                    and       a                             ;[aedb] a7
                    sbc       hl,de                         ;[aedc] ed 52
                    jp        nc,i_17_sys_fs_devfs_c        ;[aede] d2 f6 ae
                    ld        hl,$0006                      ;[aee1] 21 06 00
                    call      l_gintspsp                    ;[aee4] cd 5d a0
                    pop       bc                            ;[aee7] c1
                    pop       hl                            ;[aee8] e1
                    push      hl                            ;[aee9] e5
                    push      bc                            ;[aeea] c5
                    pop       de                            ;[aeeb] d1
                    add       hl,de                         ;[aeec] 19
                    ld        l,(hl)                        ;[aeed] 6e
                    ld        h,$00                         ;[aeee] 26 00
                    call      _putchar                      ;[aef0] cd 75 a8
                    jp        i_16_sys_fs_devfs_c           ;[aef3] c3 cd ae
i_17_sys_fs_devfs_c:
                    pop       bc                            ;[aef6] c1
                    ld        hl,$0000                      ;[aef7] 21 00 00
                    ret                                     ;[aefa] c9

_dev_zero_read:
                    ld        hl,$0000                      ;[aefb] 21 00 00
                    push      hl                            ;[aefe] e5
                    jp        i_21_sys_fs_devfs_c           ;[aeff] c3 05 af
i_19_sys_fs_devfs_c:
                    pop       hl                            ;[af02] e1
                    inc       hl                            ;[af03] 23
                    push      hl                            ;[af04] e5
i_21_sys_fs_devfs_c:
                    ld        hl,$0000                      ;[af05] 21 00 00
                    call      l_gintspsp                    ;[af08] cd 5d a0
                    call      l_gint6sp                     ;[af0b] cd 80 a0
                    pop       de                            ;[af0e] d1
                    ex        de,hl                         ;[af0f] eb
                    and       a                             ;[af10] a7
                    sbc       hl,de                         ;[af11] ed 52
                    jp        nc,i_20_sys_fs_devfs_c        ;[af13] d2 27 af
                    ld        hl,$0006                      ;[af16] 21 06 00
                    call      l_gintspsp                    ;[af19] cd 5d a0
                    pop       bc                            ;[af1c] c1
                    pop       hl                            ;[af1d] e1
                    push      hl                            ;[af1e] e5
                    push      bc                            ;[af1f] c5
                    pop       de                            ;[af20] d1
                    add       hl,de                         ;[af21] 19
                    ld        (hl),$00                      ;[af22] 36 00
                    jp        i_19_sys_fs_devfs_c           ;[af24] c3 02 af
i_20_sys_fs_devfs_c:
                    pop       bc                            ;[af27] c1
                    ld        hl,$0000                      ;[af28] 21 00 00
                    ret                                     ;[af2b] c9

_dev_zero_write:
                    ld        hl,$0000                      ;[af2c] 21 00 00
                    ret                                     ;[af2f] c9

_fd_init:
                    ld        hl,(_fd_base)                 ;[af30] 2a db d1
                    push      hl                            ;[af33] e5
                    ld        e,$00                         ;[af34] 1e 00
                    ld        b,$28                         ;[af36] 06 28
i_5_sys_fd_fd_c:
                    ld        (hl),e                        ;[af38] 73
                    inc       hl                            ;[af39] 23
                    djnz      i_5_sys_fd_fd_c               ;[af3a] 10 fc
                    pop       hl                            ;[af3c] e1
                    ld        hl,(_fd_count)                ;[af3d] 2a dd d1
                    ld        (hl),$03                      ;[af40] 36 03
                    ld        hl,(_fd_table)                ;[af42] 2a d9 d1
                    ld        (hl),$01                      ;[af45] 36 01
                    ld        hl,(_fd_table)                ;[af47] 2a d9 d1
                    ld        bc,$0005                      ;[af4a] 01 05 00
                    add       hl,bc                         ;[af4d] 09
                    ld        (hl),$01                      ;[af4e] 36 01
                    ld        hl,(_fd_table)                ;[af50] 2a d9 d1
                    ld        bc,$000a                      ;[af53] 01 0a 00
                    add       hl,bc                         ;[af56] 09
                    ld        (hl),$01                      ;[af57] 36 01
                    ld        hl,$0000                      ;[af59] 21 00 00
                    ret                                     ;[af5c] c9

_fd_alloc:
                    ld        hl,$0000                      ;[af5d] 21 00 00
                    push      hl                            ;[af60] e5
                    dec       sp                            ;[af61] 3b
                    ld        a,l                           ;[af62] 7d
                    pop       hl                            ;[af63] e1
                    ld        l,a                           ;[af64] 6f
                    push      hl                            ;[af65] e5
                    jp        i_8_sys_fd_fd_c               ;[af66] c3 6e af
i_9_sys_fd_fd_c:
                    ld        hl,$0000                      ;[af69] 21 00 00
                    add       hl,sp                         ;[af6c] 39
                    inc       (hl)                          ;[af6d] 34
i_8_sys_fd_fd_c:
                    pop       hl                            ;[af6e] e1
                    push      hl                            ;[af6f] e5
                    ld        a,l                           ;[af70] 7d
                    sub       $08                           ;[af71] d6 08
                    jp        nc,i_7_sys_fd_fd_c            ;[af73] d2 94 af
                    ld        hl,(_fd_table)                ;[af76] 2a d9 d1
                    push      hl                            ;[af79] e5
                    ld        hl,$0002                      ;[af7a] 21 02 00
                    add       hl,sp                         ;[af7d] 39
                    ld        l,(hl)                        ;[af7e] 6e
                    ld        h,$00                         ;[af7f] 26 00
                    ld        b,h                           ;[af81] 44
                    ld        c,l                           ;[af82] 4d
                    add       hl,hl                         ;[af83] 29
                    add       hl,hl                         ;[af84] 29
                    add       hl,bc                         ;[af85] 09
                    pop       de                            ;[af86] d1
                    add       hl,de                         ;[af87] 19
                    ld        a,(hl)                        ;[af88] 7e
                    and       a                             ;[af89] a7
                    jp        nz,i_9_sys_fd_fd_c            ;[af8a] c2 69 af
                    pop       hl                            ;[af8d] e1
                    push      hl                            ;[af8e] e5
                    ld        h,$00                         ;[af8f] 26 00
                    inc       sp                            ;[af91] 33
                    pop       bc                            ;[af92] c1
                    ret                                     ;[af93] c9

i_7_sys_fd_fd_c:
                    inc       sp                            ;[af94] 33
                    ld        hl,$00ff                      ;[af95] 21 ff 00
                    pop       bc                            ;[af98] c1
                    ret                                     ;[af99] c9

_fd_close:
                    push      hl                            ;[af9a] e5
                    ld        h,$00                         ;[af9b] 26 00
                    ld        a,l                           ;[af9d] 7d
                    cp        $ff                           ;[af9e] fe ff
                    jp        nz,i_10_sys_fd_fd_c           ;[afa0] c2 a8 af
                    ld        hl,$00ff                      ;[afa3] 21 ff 00
                    pop       bc                            ;[afa6] c1
                    ret                                     ;[afa7] c9

i_10_sys_fd_fd_c:
                    ld        hl,(_fd_count)                ;[afa8] 2a dd d1
                    dec       (hl)                          ;[afab] 35
                    ld        hl,(_fd_table)                ;[afac] 2a d9 d1
                    push      hl                            ;[afaf] e5
                    ld        hl,$0002                      ;[afb0] 21 02 00
                    add       hl,sp                         ;[afb3] 39
                    ld        l,(hl)                        ;[afb4] 6e
                    ld        h,$00                         ;[afb5] 26 00
                    ld        b,h                           ;[afb7] 44
                    ld        c,l                           ;[afb8] 4d
                    add       hl,hl                         ;[afb9] 29
                    add       hl,hl                         ;[afba] 29
                    add       hl,bc                         ;[afbb] 09
                    pop       de                            ;[afbc] d1
                    add       hl,de                         ;[afbd] 19
                    ld        (hl),$00                      ;[afbe] 36 00
                    ld        hl,$0000                      ;[afc0] 21 00 00
                    pop       bc                            ;[afc3] c1
                    ret                                     ;[afc4] c9

_fd_create:
                    push      hl                            ;[afc5] e5
                    call      _fd_alloc                     ;[afc6] cd 5d af
                    ld        h,$00                         ;[afc9] 26 00
                    dec       sp                            ;[afcb] 3b
                    ld        a,l                           ;[afcc] 7d
                    pop       hl                            ;[afcd] e1
                    ld        l,a                           ;[afce] 6f
                    push      hl                            ;[afcf] e5
                    ld        h,$00                         ;[afd0] 26 00
                    ld        a,l                           ;[afd2] 7d
                    cp        $ff                           ;[afd3] fe ff
                    jp        nz,i_11_sys_fd_fd_c           ;[afd5] c2 de af
                    ld        hl,$00ff                      ;[afd8] 21 ff 00
                    inc       sp                            ;[afdb] 33
                    pop       bc                            ;[afdc] c1
                    ret                                     ;[afdd] c9

i_11_sys_fd_fd_c:
                    call      l_gint1sp                     ;[afde] cd 6e a0
                    call      _get_file_blockptr            ;[afe1] cd 7d aa
                    push      hl                            ;[afe4] e5
                    ld        de,$0000                      ;[afe5] 11 00 00
                    call      l_eq                          ;[afe8] cd 40 a0
                    jp        nc,i_12_sys_fd_fd_c           ;[afeb] d2 f5 af
                    ld        hl,$00ff                      ;[afee] 21 ff 00
                    inc       sp                            ;[aff1] 33
                    pop       bc                            ;[aff2] c1
                    pop       bc                            ;[aff3] c1
                    ret                                     ;[aff4] c9

i_12_sys_fd_fd_c:
                    ld        hl,(_fd_table)                ;[aff5] 2a d9 d1
                    push      hl                            ;[aff8] e5
                    ld        hl,$0004                      ;[aff9] 21 04 00
                    add       hl,sp                         ;[affc] 39
                    ld        l,(hl)                        ;[affd] 6e
                    ld        h,$00                         ;[affe] 26 00
                    ld        b,h                           ;[b000] 44
                    ld        c,l                           ;[b001] 4d
                    add       hl,hl                         ;[b002] 29
                    add       hl,hl                         ;[b003] 29
                    add       hl,bc                         ;[b004] 09
                    pop       de                            ;[b005] d1
                    add       hl,de                         ;[b006] 19
                    ld        (hl),$01                      ;[b007] 36 01
                    ld        hl,(_fd_table)                ;[b009] 2a d9 d1
                    push      hl                            ;[b00c] e5
                    ld        hl,$0004                      ;[b00d] 21 04 00
                    add       hl,sp                         ;[b010] 39
                    ld        l,(hl)                        ;[b011] 6e
                    ld        h,$00                         ;[b012] 26 00
                    ld        b,h                           ;[b014] 44
                    ld        c,l                           ;[b015] 4d
                    add       hl,hl                         ;[b016] 29
                    add       hl,hl                         ;[b017] 29
                    add       hl,bc                         ;[b018] 09
                    pop       de                            ;[b019] d1
                    add       hl,de                         ;[b01a] 19
                    inc       hl                            ;[b01b] 23
                    pop       de                            ;[b01c] d1
                    push      de                            ;[b01d] d5
                    push      hl                            ;[b01e] e5
                    ex        de,hl                         ;[b01f] eb
                    ld        bc,$0008                      ;[b020] 01 08 00
                    add       hl,bc                         ;[b023] 09
                    pop       de                            ;[b024] d1
                    call      l_pint                        ;[b025] cd 95 a0
                    ld        hl,(_fd_table)                ;[b028] 2a d9 d1
                    push      hl                            ;[b02b] e5
                    ld        hl,$0004                      ;[b02c] 21 04 00
                    add       hl,sp                         ;[b02f] 39
                    ld        l,(hl)                        ;[b030] 6e
                    ld        h,$00                         ;[b031] 26 00
                    ld        b,h                           ;[b033] 44
                    ld        c,l                           ;[b034] 4d
                    add       hl,hl                         ;[b035] 29
                    add       hl,hl                         ;[b036] 29
                    add       hl,bc                         ;[b037] 09
                    pop       de                            ;[b038] d1
                    add       hl,de                         ;[b039] 19
                    inc       hl                            ;[b03a] 23
                    inc       hl                            ;[b03b] 23
                    inc       hl                            ;[b03c] 23
                    pop       de                            ;[b03d] d1
                    push      de                            ;[b03e] d5
                    push      hl                            ;[b03f] e5
                    ex        de,hl                         ;[b040] eb
                    ld        bc,$0008                      ;[b041] 01 08 00
                    add       hl,bc                         ;[b044] 09
                    pop       de                            ;[b045] d1
                    call      l_pint                        ;[b046] cd 95 a0
                    ld        hl,(_fd_count)                ;[b049] 2a dd d1
                    inc       (hl)                          ;[b04c] 34
                    ld        hl,$0002                      ;[b04d] 21 02 00
                    add       hl,sp                         ;[b050] 39
                    ld        l,(hl)                        ;[b051] 6e
                    ld        h,$00                         ;[b052] 26 00
                    inc       sp                            ;[b054] 33
                    pop       bc                            ;[b055] c1
                    pop       bc                            ;[b056] c1
                    ret                                     ;[b057] c9

_fd_get:
                    ld        hl,$0006                      ;[b058] 21 06 00
                    add       hl,sp                         ;[b05b] 39
                    ld        a,(hl)                        ;[b05c] 7e
                    cp        $ff                           ;[b05d] fe ff
                    jp        nz,i_13_sys_fd_fd_c           ;[b05f] c2 66 b0
                    ld        hl,$00ff                      ;[b062] 21 ff 00
                    ret                                     ;[b065] c9

i_13_sys_fd_fd_c:
                    call      l_gint4sp                     ;[b066] cd 77 a0
                    ld        a,h                           ;[b069] 7c
                    or        l                             ;[b06a] b5
                    jp        z,i_14_sys_fd_fd_c            ;[b06b] ca 8b b0
                    call      l_gint4sp                     ;[b06e] cd 77 a0
                    push      hl                            ;[b071] e5
                    ld        hl,(_fd_table)                ;[b072] 2a d9 d1
                    push      hl                            ;[b075] e5
                    ld        hl,$000a                      ;[b076] 21 0a 00
                    add       hl,sp                         ;[b079] 39
                    ld        l,(hl)                        ;[b07a] 6e
                    ld        h,$00                         ;[b07b] 26 00
                    ld        b,h                           ;[b07d] 44
                    ld        c,l                           ;[b07e] 4d
                    add       hl,hl                         ;[b07f] 29
                    add       hl,hl                         ;[b080] 29
                    add       hl,bc                         ;[b081] 09
                    pop       de                            ;[b082] d1
                    add       hl,de                         ;[b083] 19
                    call      l_gint1                       ;[b084] cd 68 a0
                    pop       de                            ;[b087] d1
                    call      l_pint                        ;[b088] cd 95 a0
i_14_sys_fd_fd_c:
                    pop       bc                            ;[b08b] c1
                    pop       hl                            ;[b08c] e1
                    push      hl                            ;[b08d] e5
                    push      bc                            ;[b08e] c5
                    ld        a,h                           ;[b08f] 7c
                    or        l                             ;[b090] b5
                    jp        z,i_15_sys_fd_fd_c            ;[b091] ca b2 b0
                    pop       bc                            ;[b094] c1
                    pop       hl                            ;[b095] e1
                    push      hl                            ;[b096] e5
                    push      bc                            ;[b097] c5
                    push      hl                            ;[b098] e5
                    ld        hl,(_fd_table)                ;[b099] 2a d9 d1
                    push      hl                            ;[b09c] e5
                    ld        hl,$000a                      ;[b09d] 21 0a 00
                    add       hl,sp                         ;[b0a0] 39
                    ld        l,(hl)                        ;[b0a1] 6e
                    ld        h,$00                         ;[b0a2] 26 00
                    ld        b,h                           ;[b0a4] 44
                    ld        c,l                           ;[b0a5] 4d
                    add       hl,hl                         ;[b0a6] 29
                    add       hl,hl                         ;[b0a7] 29
                    add       hl,bc                         ;[b0a8] 09
                    pop       de                            ;[b0a9] d1
                    add       hl,de                         ;[b0aa] 19
                    call      l_gint3                       ;[b0ab] cd 66 a0
                    pop       de                            ;[b0ae] d1
                    call      l_pint                        ;[b0af] cd 95 a0
i_15_sys_fd_fd_c:
                    ld        hl,$0000                      ;[b0b2] 21 00 00
                    ret                                     ;[b0b5] c9

asm_dzx7_standard:
                    ld        a,$80                         ;[b0b6] 3e 80
dzx7s_copy_byte_loop:
                    ldi                                     ;[b0b8] ed a0
dzx7s_main_loop:
                    call      dzx7s_next_bit                ;[b0ba] cd f7 b0
                    jr        nc,dzx7s_copy_byte_loop       ;[b0bd] 30 f9
                    push      de                            ;[b0bf] d5
                    ld        bc,$0000                      ;[b0c0] 01 00 00
                    ld        d,b                           ;[b0c3] 50
dzx7s_len_size_loop:
                    inc       d                             ;[b0c4] 14
                    call      dzx7s_next_bit                ;[b0c5] cd f7 b0
                    jr        nc,dzx7s_len_size_loop        ;[b0c8] 30 fa
dzx7s_len_value_loop:
                    call      nc,dzx7s_next_bit             ;[b0ca] d4 f7 b0
                    rl        c                             ;[b0cd] cb 11
                    rl        b                             ;[b0cf] cb 10
                    jp        c,$a09d                       ;[b0d1] da 9d a0
                    dec       d                             ;[b0d4] 15
                    jr        nz,dzx7s_len_value_loop       ;[b0d5] 20 f3
                    inc       bc                            ;[b0d7] 03
                    ld        e,(hl)                        ;[b0d8] 5e
                    inc       hl                            ;[b0d9] 23
                    sla       e                             ;[b0da] cb 23
                    inc       e                             ;[b0dc] 1c
                    jr        nc,dzx7s_offset_end           ;[b0dd] 30 0c
                    ld        d,$10                         ;[b0df] 16 10
dzx7s_rld_next_bit:
                    call      dzx7s_next_bit                ;[b0e1] cd f7 b0
                    rl        d                             ;[b0e4] cb 12
                    jr        nc,dzx7s_rld_next_bit         ;[b0e6] 30 f9
                    inc       d                             ;[b0e8] 14
                    srl       d                             ;[b0e9] cb 3a
dzx7s_offset_end:
                    rr        e                             ;[b0eb] cb 1b
                    ex        (sp),hl                       ;[b0ed] e3
                    push      hl                            ;[b0ee] e5
                    sbc       hl,de                         ;[b0ef] ed 52
                    pop       de                            ;[b0f1] d1
                    ldir                                    ;[b0f2] ed b0
dzx7s_exit:
                    pop       hl                            ;[b0f4] e1
                    jr        nc,dzx7s_main_loop            ;[b0f5] 30 c3
dzx7s_next_bit:
                    add       a                             ;[b0f7] 87
                    ret       nz                            ;[b0f8] c0
                    ld        a,(hl)                        ;[b0f9] 7e
                    inc       hl                            ;[b0fa] 23
                    rla                                     ;[b0fb] 17
                    ret                                     ;[b0fc] c9

___strcmp_callee:
                    pop       bc                            ;[b0fd] c1
                    pop       hl                            ;[b0fe] e1
                    pop       de                            ;[b0ff] d1
                    push      bc                            ;[b100] c5
                    jp        asm_strcmp                    ;[b101] c3 0c b1
___strncpy_callee:
                    pop       hl                            ;[b104] e1
                    pop       bc                            ;[b105] c1
                    pop       de                            ;[b106] d1
                    ex        (sp),hl                       ;[b107] e3
                    ex        de,hl                         ;[b108] eb
                    jp        asm_strncpy                   ;[b109] c3 28 b1
asm_strcmp:
                    ld        a,(de)                        ;[b10c] 1a
                    cpi                                     ;[b10d] ed a1
                    jr        nz,different                  ;[b10f] 20 08
                    inc       de                            ;[b111] 13
                    or        a                             ;[b112] b7
                    jr        nz,asm_strcmp                 ;[b113] 20 f7
equal:
                    dec       de                            ;[b115] 1b
                    ld        l,a                           ;[b116] 6f
                    ld        h,a                           ;[b117] 67
                    ret                                     ;[b118] c9

different:
                    dec       hl                            ;[b119] 2b
                    sub       (hl)                          ;[b11a] 96
                    ld        h,a                           ;[b11b] 67
                    ret                                     ;[b11c] c9

___strlen_fastcall:
                    xor       a                             ;[b11d] af
                    ld        c,a                           ;[b11e] 4f
                    ld        b,a                           ;[b11f] 47
                    cpir                                    ;[b120] ed b1
                    ld        hl,$ffff                      ;[b122] 21 ff ff
                    sbc       hl,bc                         ;[b125] ed 42
                    ret                                     ;[b127] c9

asm_strncpy:
                    push      de                            ;[b128] d5
                    ld        a,b                           ;[b129] 78
                    or        c                             ;[b12a] b1
                    jr        z,done                        ;[b12b] 28 0e
                    xor       a                             ;[b12d] af
loop_asm_strncpy:
                    cp        (hl)                          ;[b12e] be
                    ldi                                     ;[b12f] ed a0
                    jp        po,done                       ;[b131] e2 3b b1
                    jr        nz,loop_asm_strncpy           ;[b134] 20 f8
                    ld        h,d                           ;[b136] 62
                    ld        l,e                           ;[b137] 6b
                    dec       hl                            ;[b138] 2b
                    ldir                                    ;[b139] ed b0
done:
                    pop       hl                            ;[b13b] e1
                    ret                                     ;[b13c] c9

i_1:
                    defb      $0a                           ;[b13d] 0a
                    defb      $0d                           ;[b13e] 0d
                    defb      $00                           ;[b13f] 00
                    defb      $54                           ;[b140] 54
                    defb      $65                           ;[b141] 65
                    defb      $73                           ;[b142] 73
                    defb      $74                           ;[b143] 74
                    defb      $20                           ;[b144] 20
                    defb      $66                           ;[b145] 66
                    defb      $75                           ;[b146] 75
                    defb      $6e                           ;[b147] 6e
                    defb      $63                           ;[b148] 63
                    defb      $74                           ;[b149] 74
                    defb      $69                           ;[b14a] 69
                    defb      $6f                           ;[b14b] 6f
                    defb      $6e                           ;[b14c] 6e
                    defb      $20                           ;[b14d] 20
                    defb      $63                           ;[b14e] 63
                    defb      $61                           ;[b14f] 61
                    defb      $6c                           ;[b150] 6c
                    defb      $6c                           ;[b151] 6c
                    defb      $65                           ;[b152] 65
                    defb      $64                           ;[b153] 64
                    defb      $0a                           ;[b154] 0a
                    defb      $0d                           ;[b155] 0d
                    defb      $00                           ;[b156] 00
                    defb      $3e                           ;[b157] 3e
                    defb      $20                           ;[b158] 20
                    defb      $00                           ;[b159] 00
                    defb      $65                           ;[b15a] 65
                    defb      $78                           ;[b15b] 78
                    defb      $69                           ;[b15c] 69
                    defb      $74                           ;[b15d] 74
                    defb      $00                           ;[b15e] 00
                    defb      $75                           ;[b15f] 75
                    defb      $6e                           ;[b160] 6e
                    defb      $61                           ;[b161] 61
                    defb      $6d                           ;[b162] 6d
                    defb      $65                           ;[b163] 65
                    defb      $00                           ;[b164] 00
                    defb      $63                           ;[b165] 63
                    defb      $6c                           ;[b166] 6c
                    defb      $65                           ;[b167] 65
                    defb      $61                           ;[b168] 61
                    defb      $72                           ;[b169] 72
                    defb      $00                           ;[b16a] 00
                    defb      $70                           ;[b16b] 70
                    defb      $69                           ;[b16c] 69
                    defb      $64                           ;[b16d] 64
                    defb      $00                           ;[b16e] 00
                    defb      $70                           ;[b16f] 70
                    defb      $63                           ;[b170] 63
                    defb      $6f                           ;[b171] 6f
                    defb      $75                           ;[b172] 75
                    defb      $6e                           ;[b173] 6e
                    defb      $74                           ;[b174] 74
                    defb      $00                           ;[b175] 00
                    defb      $6c                           ;[b176] 6c
                    defb      $73                           ;[b177] 73
                    defb      $64                           ;[b178] 64
                    defb      $65                           ;[b179] 65
                    defb      $76                           ;[b17a] 76
                    defb      $00                           ;[b17b] 00
                    defb      $6c                           ;[b17c] 6c
                    defb      $73                           ;[b17d] 73
                    defb      $00                           ;[b17e] 00
                    defb      $72                           ;[b17f] 72
                    defb      $64                           ;[b180] 64
                    defb      $75                           ;[b181] 75
                    defb      $6d                           ;[b182] 6d
                    defb      $70                           ;[b183] 70
                    defb      $00                           ;[b184] 00
                    defb      $74                           ;[b185] 74
                    defb      $65                           ;[b186] 65
                    defb      $73                           ;[b187] 73
                    defb      $74                           ;[b188] 74
                    defb      $00                           ;[b189] 00
                    defb      $54                           ;[b18a] 54
                    defb      $45                           ;[b18b] 45
                    defb      $53                           ;[b18c] 53
                    defb      $54                           ;[b18d] 54
                    defb      $45                           ;[b18e] 45
                    defb      $58                           ;[b18f] 58
                    defb      $45                           ;[b190] 45
                    defb      $00                           ;[b191] 00
                    defb      $46                           ;[b192] 46
                    defb      $61                           ;[b193] 61
                    defb      $69                           ;[b194] 69
                    defb      $6c                           ;[b195] 6c
                    defb      $65                           ;[b196] 65
                    defb      $64                           ;[b197] 64
                    defb      $20                           ;[b198] 20
                    defb      $74                           ;[b199] 74
                    defb      $6f                           ;[b19a] 6f
                    defb      $20                           ;[b19b] 20
                    defb      $67                           ;[b19c] 67
                    defb      $65                           ;[b19d] 65
                    defb      $74                           ;[b19e] 74
                    defb      $20                           ;[b19f] 20
                    defb      $66                           ;[b1a0] 66
                    defb      $69                           ;[b1a1] 69
                    defb      $6c                           ;[b1a2] 6c
                    defb      $65                           ;[b1a3] 65
                    defb      $20                           ;[b1a4] 20
                    defb      $62                           ;[b1a5] 62
                    defb      $6c                           ;[b1a6] 6c
                    defb      $6f                           ;[b1a7] 6f
                    defb      $63                           ;[b1a8] 63
                    defb      $6b                           ;[b1a9] 6b
                    defb      $20                           ;[b1aa] 20
                    defb      $70                           ;[b1ab] 70
                    defb      $6f                           ;[b1ac] 6f
                    defb      $69                           ;[b1ad] 69
                    defb      $6e                           ;[b1ae] 6e
                    defb      $74                           ;[b1af] 74
                    defb      $65                           ;[b1b0] 65
                    defb      $72                           ;[b1b1] 72
                    defb      $0a                           ;[b1b2] 0a
                    defb      $0d                           ;[b1b3] 0d
                    defb      $00                           ;[b1b4] 00
                    defb      $72                           ;[b1b5] 72
                    defb      $65                           ;[b1b6] 65
                    defb      $74                           ;[b1b7] 74
                    defb      $00                           ;[b1b8] 00
                    defb      $65                           ;[b1b9] 65
                    defb      $63                           ;[b1ba] 63
                    defb      $00                           ;[b1bb] 00
                    defb      $74                           ;[b1bc] 74
                    defb      $65                           ;[b1bd] 65
                    defb      $73                           ;[b1be] 73
                    defb      $74                           ;[b1bf] 74
                    defb      $66                           ;[b1c0] 66
                    defb      $75                           ;[b1c1] 75
                    defb      $6e                           ;[b1c2] 6e
                    defb      $63                           ;[b1c3] 63
                    defb      $00                           ;[b1c4] 00
                    defb      $55                           ;[b1c5] 55
                    defb      $6e                           ;[b1c6] 6e
                    defb      $6b                           ;[b1c7] 6b
                    defb      $6e                           ;[b1c8] 6e
                    defb      $6f                           ;[b1c9] 6f
                    defb      $77                           ;[b1ca] 77
                    defb      $6e                           ;[b1cb] 6e
                    defb      $20                           ;[b1cc] 20
                    defb      $63                           ;[b1cd] 63
                    defb      $6f                           ;[b1ce] 6f
                    defb      $6d                           ;[b1cf] 6d
                    defb      $6d                           ;[b1d0] 6d
                    defb      $61                           ;[b1d1] 61
                    defb      $6e                           ;[b1d2] 6e
                    defb      $64                           ;[b1d3] 64
                    defb      $0a                           ;[b1d4] 0a
                    defb      $0d                           ;[b1d5] 0d
                    defb      $00                           ;[b1d6] 00
                    nop                                     ;[b1d7] 00
                    inc       bc                            ;[b1d8] 03
                    ld        c,l                           ;[b1d9] 4d
                    ld        h,c                           ;[b1da] 61
                    ld        l,(hl)                        ;[b1db] 6e
                    ld        (hl),l                        ;[b1dc] 75
                    ld        a,b                           ;[b1dd] 78
                    jr        nz,$b1e0                      ;[b1de] 20 00
                    ld        (bc),a                        ;[b1e0] 02
                    ld        e,d                           ;[b1e1] 5a
                    jr        c,$b214                       ;[b1e2] 38 30
                    dec       l                             ;[b1e4] 2d
                    ld        d,b                           ;[b1e5] 50
                    ld        b,e                           ;[b1e6] 43
                    add       a                             ;[b1e7] 87
                    ex        af,af'                        ;[b1e8] 08
                    jr        nc,$b219                      ;[b1e9] 30 2e
                    inc       sp                            ;[b1eb] 33
                    inc       b                             ;[b1ec] 04
                    adc       e                             ;[b1ed] 8b
                    nop                                     ;[b1ee] 00
                    ld        h,h                           ;[b1ef] 64
                    ld        h,l                           ;[b1f0] 65
                    halt                                    ;[b1f1] 76
                    ld        b,$92                         ;[b1f2] 06 92
                    jr        $b176                         ;[b1f4] 18 80
                    dec       b                             ;[b1f6] 05
                    nop                                     ;[b1f7] 00
                    ld        c,b                           ;[b1f8] 48
                    ld        h,l                           ;[b1f9] 65
                    ld        l,h                           ;[b1fa] 6c
                    ld        l,h                           ;[b1fb] 6c
                    ld        l,a                           ;[b1fc] 6f
                    ex        af,af'                        ;[b1fd] 08
                    ld        (hl),d                        ;[b1fe] 72
                    ld        h,h                           ;[b1ff] 64
                    dec       c                             ;[b200] 0d
                    ld        a,(bc)                        ;[b201] 0a
                    add       hl,de                         ;[b202] 19
                    nop                                     ;[b203] 00
                    ld        sp,$a246                      ;[b204] 31 46 a2
                    ld        d,d                           ;[b207] 52
                    and       d                             ;[b208] a2
                    ld        h,c                           ;[b209] 61
                    and       d                             ;[b20a] a2
                    nop                                     ;[b20b] 00
                    ld        (hl),b                        ;[b20c] 70
                    and       d                             ;[b20d] a2
                    sbc       h                             ;[b20e] 9c
                    and       d                             ;[b20f] a2
                    xor       (hl)                          ;[b210] ae
                    and       d                             ;[b211] a2
                    jp        nz,$00a2                      ;[b212] c2 a2 00
                    pop       de                            ;[b215] d1
                    and       d                             ;[b216] a2
                    sbc       $a2                           ;[b217] de a2
                    pop       hl                            ;[b219] e1
                    and       d                             ;[b21a] a2
                    jp        pe,$00a2                      ;[b21b] ea a2 00
                    ld        sp,hl                         ;[b21e] f9
                    and       d                             ;[b21f] a2
                    dec       b                             ;[b220] 05
                    and       e                             ;[b221] a3
                    inc       de                            ;[b222] 13
                    and       e                             ;[b223] a3
                    ld        hl,$00a3                      ;[b224] 21 a3 00
                    cpl                                     ;[b227] 2f
                    and       e                             ;[b228] a3
                    nop                                     ;[b229] 00
                    nop                                     ;[b22a] 00
                    ld        a,$4f                         ;[b22b] 3e 4f
                    rst       $08                           ;[b22d] cf
                    ld        a,$60                         ;[b22e] 3e 60
                    ld        c,e                           ;[b230] 4b
                    ld        (bc),a                        ;[b231] 02
                    nop                                     ;[b232] 00
                    ld        l,$03                         ;[b233] 2e 03
                    call      $0100                         ;[b235] cd 00 01
                    and       b                             ;[b238] a0
                    djnz      $b262                         ;[b239] 10 27
                    ret       pe                            ;[b23b] e8
                    inc       bc                            ;[b23c] 03
                    ld        h,h                           ;[b23d] 64
                    nop                                     ;[b23e] 00
                    add       e                             ;[b23f] 83
                    ld        (hl),$01                      ;[b240] 36 01
                    nop                                     ;[b242] 00
                    ld        (bc),a                        ;[b243] 02
                    ret       p                             ;[b244] f0
                    nop                                     ;[b245] 00
                    ld        bc,$f150                      ;[b246] 01 50 f1
                    inc       bc                            ;[b249] 03
                    sub       d                             ;[b24a] 92
                    cp        $91                           ;[b24b] fe 91
                    jr        $b2c3                         ;[b24d] 18 74
                    ld        (hl),h                        ;[b24f] 74
                    ld        a,c                           ;[b250] 79
                    ld        d,e                           ;[b251] 53
                    ld        h,e                           ;[b252] 63
                    sub       b                             ;[b253] 90
                    xor       (hl)                          ;[b254] ae
                    inc       bc                            ;[b255] 03
                    add       $ae                           ;[b256] c6 ae
                    ld        a,d                           ;[b258] 7a
                    ld        h,l                           ;[b259] 65
                    ld        (hl),d                        ;[b25a] 72
                    ld        l,a                           ;[b25b] 6f
                    add       hl,bc                         ;[b25c] 09
                    inc       c                             ;[b25d] 0c
                    ei                                      ;[b25e] fb
                    xor       (hl)                          ;[b25f] ae
                    inc       l                             ;[b260] 2c
                    xor       a                             ;[b261] af
                    adc       b                             ;[b262] 88
                    add       hl,sp                         ;[b263] 39
                    ld        h,d                           ;[b264] 62
                    ld        c,h                           ;[b265] 4c
                    add       hl,bc                         ;[b266] 09
                    nop                                     ;[b267] 00
                    sub       c                             ;[b268] 91
                    ld        bc,$90fe                      ;[b269] 01 fe 90
                    ld        bc,$7453                      ;[b26c] 01 53 74
                    ld        h,c                           ;[b26f] 61
                    ld        h,e                           ;[b270] 63
                    ld        l,e                           ;[b271] 6b
                    ld        (hl),h                        ;[b272] 74
                    ld        (hl),d                        ;[b273] 72
                    sbc       b                             ;[b274] 98
                    inc       b                             ;[b275] 04
                    ld        h,l                           ;[b276] 65
                    ld        a,($202b)                     ;[b277] 3a 2b 20
                    ld        b,c                           ;[b27a] 41
                    ld        b,(hl)                        ;[b27b] 46
                    or        d                             ;[b27c] b2
                    dec       b                             ;[b27d] 05
                    ld        b,d                           ;[b27e] 42
                    ld        b,e                           ;[b27f] 43
                    rlc       l                             ;[b280] cb 05
                    ld        b,h                           ;[b282] 44
                    ld        b,l                           ;[b283] 45
                    dec       b                             ;[b284] 05
                    inc       l                             ;[b285] 2c
                    ld        c,b                           ;[b286] 48
                    ld        c,h                           ;[b287] 4c
                    dec       b                             ;[b288] 05
                    ld        c,c                           ;[b289] 49
                    ld        e,b                           ;[b28a] 58
                    sub       c                             ;[b28b] 91
                    dec       b                             ;[b28c] 05
                    ld        e,c                           ;[b28d] 59
                    ld        h,l                           ;[b28e] 65
                    dec       b                             ;[b28f] 05
                    ld        d,e                           ;[b290] 53
                    ld        d,b                           ;[b291] 50
                    ld        b,b                           ;[b292] 40
                    dec       b                             ;[b293] 05
                    nop                                     ;[b294] 00
                    jr        nz,$b297                      ;[b295] 20 00
