## (setq comment-start "##")
.set P1DDR,   0xfe80
.set P2DDR,   0xfe81
.set P1DR,    0xfe82
.set P2DR,    0xfe83
.set P3DDR,   0xfe84
.set P4DDR,   0xfe85
.set P3DR,    0xfe86
.set P4DR,    0xfe87
.set P5DDR,   0xfe88
.set P6DDR,   0xfe89
.set P5DR,    0xfe8a
.set P6DR,    0xfe8b
.set SCI1SMR, 0xfec8
.set SCI1BRR, 0xfec9
.set SCI1SCR, 0xfeca
.set SCI1TDR, 0xfecb
.set SCI1SSR, 0xfecc
.set SCI1RDR, 0xfecd
.set SCI2SMR, 0xfed0
.set SCI2BRR, 0xfed1
.set SCI2SCR, 0xfed2
.set SCI2TDR, 0xfed3
.set SCI2SSR, 0xfed4
.set SCI2RDR, 0xfed5
.set FLMCR,   0xfee0
.set RSTCSR,  0xff1f
.set TCSR,    0xff10
.set TCNT,    0xff11
.set WCR,     0xff14
.set RAMCR,   0xff15
.set MDCR,    0xff19

start:
    LDC.W    #0x0700  , sr
    CLR.B    @WCR
    MOV.W    #0xfe80  , sp
    MOV.B    #0x0:8   , r0
setup_serial:
    MOV.B    r0       , @SCI1SCR
    MOV.B    r0       , @SCI1SMR
    MOV.B    #0x7:8   , @SCI1BRR
    MOV.B    @SCI1RDR , r0
    MOV.B    #0xc7:8  , r0
    AND.B    @SCI1SSR , r0
    MOV.B    r0       , @SCI1SSR
    MOV.B    #0x30:8  , @SCI1SCR

byte_loop:
    MOV.W    #0x07D0  , r1
    MOV.W    @r1      , r0
    BSR      FUN_SendChar
    SCB/f    r1       , byte_loop

infinite_loop:
    BRA      infinite_loop

    ## FUN_SendChar sends a single character over SCI1, blocking.
    ## Inputs:
    ## r0: the byte to send
FUN_SendChar:
    STM      (r0-r3)  , @-sp
    MOV.W    #SCI1SSR , r3
    MOV.B    r0       , r1
    MOV.W    #0x200   , r2
    MOV.B    #0xc7:8  , r0
    AND.B    @r3      , r0
    MOV.B    r0       , @r3
    BTST.B   #0x6     , @r3
    BEQ      LAB_f49c
    ## PLAN: Why do we bother reading SCIRDR?
    MOV.B    @SCI1RDR , r0
    MOV.B    #0x87:8  , r0
    AND.B    @r3      , r0
    MOV.B    r0       , @r3

LAB_f49c:
    MOV.B    @0xfbfe  , r0
    ADD.B    r1       , r0
    MOV.B    r0       , @0xfbfe

LAB_f4a6:
    BTST.B   #0x7     , @r3
    BEQ      LAB_f4a6
    MOV.B    r1       , @SCI1TDR
    MOV.B    #0x7f:8  , r0
    AND.B    @r3      , r0
    MOV.B    r0       , @r3

LAB_f4b4:
    MOV.B    #0xc7:8  , r0
    AND.B    @r3      , r0
    MOV.B    r0       , @r3
    BTST.B   #0x6     , @r3
    BEQ      LAB_f4cc
    MOV.B    @SCI1RDR , r0
    MOV.B    #0x87:8  , r0
    AND.B    @r3      , r0
    MOV.B    r0       , @r3
    LDM      @sp+     , (r0-r3)
    RTS
    
LAB_f4cc:
    SCB/f    r2       , LAB_f4b4
    LDM      @sp+     , (r0-r3)
    RTS
## END: FUN_SendChar
