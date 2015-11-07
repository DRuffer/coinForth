; ( -- xt ) (C: "<space>name" -- ) 
; Compiler
; what ' does in the interpreter mode, do in colon definitions

.if cpu_msp430==1
    IMMED(XT_BRACKETTICK,3,"[']",DOCOLON)
.endif

.if cpu_avr8==1
VE_BRACKETTICK:
    .dw $0003
    .db "[']",0
    .dw VE_HEAD
    .set VE_HEAD = VE_BRACKETTICK
XT_BRACKETTICK:
    .dw DO_COLON
PFA_BRACKETTICK:
.endif
    .dw XT_TICK
    .dw XT_LITERAL
    .dw XT_EXIT
