; ( -- ) (C: dest -- ) 
; Compiler
; compile a jump back to dest

.if cpu_msp430==1
    IMMED(XT_AGAIN,5,"again",DOCOLON)
.endif

.if cpu_avr8==1
VE_AGAIN:
    .dw $0005
    .db "again",0
    .dw VE_HEAD
    .set VE_HEAD = VE_AGAIN
XT_AGAIN:
    .dw DO_COLON
PFA_AGAIN:
.endif
    .dw XT_COMPILE
    .dw XT_DOBRANCH
    .dw XT_LRESOLVE
    .dw XT_EXIT
