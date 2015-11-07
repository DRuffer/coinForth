; ( f -- ) (C: dest -- orig dest ) 
; Compiler
; at runtime skip until repeat if non-true

.if cpu_msp430==1
    IMMED(XT_WHILE,5,"while",DOCOLON)
.endif

.if cpu_avr8==1
VE_WHILE:
    .dw $0005
    .db "while",0
    .dw VE_HEAD
    .set VE_HEAD = VE_WHILE
XT_WHILE:
    .dw DO_COLON
PFA_WHILE:
.endif
    .dw XT_IF
    .dw XT_SWAP
    .dw XT_EXIT
