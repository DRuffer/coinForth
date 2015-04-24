; ( f -- ) (C: -- orig )
; Compiler
; start conditional branch

.if cpu_msp430==1
    IMMED(XT_IF,2,"if",DOCOLON)
.endif

.if cpu_avr8==1
VE_IF:
    .dw $0002
    .db "if"
    .dw VE_HEAD
    .set VE_HEAD = VE_IF
XT_IF:
    .dw DO_COLON
PFA_IF:
.endif
    .dw XT_COMPILE
    .dw XT_DOCONDBRANCH
    .dw XT_GMARK
    .dw XT_EXIT
