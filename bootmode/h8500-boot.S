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

.set EBR1, 0xFEE2
.set EBR2, 0xFEE3
    
start:
    LDC.W    #0x0700  , sr
    CLR.B    @WCR
    MOV.W    #0xfe80  , sp
    MOV.B    #0x0:8   , r0
setup_serial:
    MOV.B    r0       , @SCI1SCR
    MOV.B    r0       , @SCI1SMR # 0 = CKS1 = CKS0, so system clock undivided
    MOV.B    #0x40:8  , @SCI1BRR # N = 64. At 10MHz CPU clock and with 0 CKS0/1, this is 4800 baud.
    ;; MOV.B    #0xc7:8  , r0       # Clear any existing overrun, framing or parity errors.
    ;; AND.B    @SCI1SSR , r0
    ;; MOV.B    r0       , @SCI1SSR
    MOV.B    #0x30:8  , @SCI1SCR # 00110000 - Enable transmit and receive

byte_loop:
    MOV.W    #0x07D0  , r1
    MOV.W    @r1      , r0
    BSR      FUN_SendChar
    SCB/f    r1       , byte_loop

NGEND:  
infinite_loop:
    BRA      infinite_loop

    ## FUN_SendChar sends a single character over SCI1, blocking.
    ## Inputs:
    ## r0: the byte to send
FUN_SendChar:
    STM      (r0-r3)  , @-sp
    MOV.W    #SCI1SSR , r3
    MOV.B    r0       , r1

_SendChar_TXWait:
    ## Loop until TDR is ready to accept a new byte to send:
    BTST.B   #0x7     , @r3    # If TDRE=0, set Z=1,
    BEQ      _SendChar_TXWait  # and loop back to _SendChar_TXWait

    MOV.B    r1       , @SCI1TDR

    ## Clear the SSR TDRE bit
    ## PLAN: Isn't TDRE already unset when you copy something into the TDR?
    BCLR.B   #0x7     , @r3
    LDM      @sp+     , (r0-r3)
    RTS

    ## END: FUN_SendChar

FUN_ProgramByte:
    STM      (r0-r3)  , @-sp
                                 ;; LDC.B #FE, BR ;Set base register
_ProgramByte_PRGM:
    MOV.W #0001, r0              ;Program-verify fail count
_ProgramByte_PRGMS:
    MOV.B r3, @r2                ;Dummy write
    MOV.W #0xA578, @TCSR         ;Start watchdog timer
    MOV.W #0xa, r1               ;Set program loop counter
    MOV.B #0x01, @FLMCR:8        ;Set P bit
_ProgramByte_LOOP1:
    SCB/f r1, _ProgramByte_LOOP1 ;Program
    CLR.B @FLMCR:8               ;Clear P bit
    MOV.W #0xA500, @TCSR         ;Stop watchdog timer
    MOV.W #0xb , r1              ;Set program-verify loop counter
    MOV.B #04, @FLMCR:8          ;Set PV bit
_ProgramByte_LOOP2:
    SCB/f r1, _ProgramByte_LOOP2 ;Wait
    MOV.B @r2, r1                ;Read programmed address
    CMP.B r3, r1                 ;Compare programmed data with read data
    BEQ _ProgramByte_PV0K        ;Program-verify decision
_ProgramByte_PVNG:
    CLR.B @FLMCR:8               ;Clear PV bit
    CMP.W #0x0014, r0            ;Program-verify executed 20 times?
    BEQ NGEND                    ;If program-verify executed 20 times, branch to NGEND
    ADD.W #0x1, r0               ;Increment program-verify fail count in r0
    BRA _ProgramByte_PRGMS       ;Program again
_ProgramByte_PV0K:
    CLR.B @FLMCR:8               ;Clear PV bit
    LDM      @sp+, (r0-r3)
    RTS
