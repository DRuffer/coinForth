; ( --  ) (C: orig dest -- )
; Compiler
; continue execution at dest, resolve orig

.if cpu_msp430==1
    IMMED(XT_REPEAT,6,"repeat",DOCOLON)
.endif

.if cpu_avr8==1
VE_REPEAT:
    .dw $0006
    .db "repeat"
    .dw VE_HEAD
    .set VE_HEAD = VE_REPEAT
XT_REPEAT:
    .dw DO_COLON
PFA_REPEAT:
.endif
    .dw XT_AGAIN
    .dw XT_THEN
    .dw XT_EXIT
