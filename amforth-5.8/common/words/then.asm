; ( -- ) (C: orig -- ) 
; Compiler
; finish if

.if cpu_msp430==1
    IMMED(XT_THEN,4,"then",DOCOLON)
.endif

.if cpu_avr8==1
VE_THEN:
    .dw $0004
    .db "then"
    .dw VE_HEAD
    .set VE_HEAD = VE_THEN
XT_THEN:
    .dw DO_COLON
PFA_THEN:
.endif
    .dw XT_GRESOLVE
    .dw XT_EXIT
