; ( n -- ) (R: loop-sys -- loop-sys| ) (C: do-sys -- )
; Compiler
; compile (+loop) and resolve branches

.if cpu_msp430==1
    IMMED(XT_PLUSLOOP,5,"+loop",DOCOLON)
.endif

.if cpu_avr8==1
VE_PLUSLOOP:
    .dw $0005
    .db "+loop",0
    .dw VE_HEAD
    .set VE_HEAD = VE_PLUSLOOP
XT_PLUSLOOP:
    .dw DO_COLON
PFA_PLUSLOOP:
.endif
    .dw XT_COMPILE
    .dw XT_DOPLUSLOOP
    .dw XT_ENDLOOP
    .dw XT_EXIT
