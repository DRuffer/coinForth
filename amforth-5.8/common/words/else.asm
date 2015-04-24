; (C: orig1 -- orig2 ) 
; Compiler
; resolve the forward reference and place a new unresolved forward reference

.if cpu_msp430==1
    IMMED(XT_ELSE,4,"else",DOCOLON)
.endif

.if cpu_avr8==1
VE_ELSE:
    .dw $0004
    .db "else"
    .dw VE_HEAD
    .set VE_HEAD = VE_ELSE
XT_ELSE:
    .dw DO_COLON
PFA_ELSE:
.endif
    .dw XT_COMPILE
    .dw XT_DOBRANCH
    .dw XT_GMARK
    .dw XT_SWAP
    .dw XT_GRESOLVE
    .dw XT_EXIT
