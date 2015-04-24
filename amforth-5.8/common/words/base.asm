; ( -- a-addr ) 
; Numeric IO
; location of the cell containing the number conversion radix

.if cpu_msp430==1
    HEADER(XT_BASE,4,"base",DOUSER)
.endif

.if cpu_avr8==1
VE_BASE:
    .dw $ff04
    .db "base"
    .dw VE_HEAD
    .set VE_HEAD = VE_BASE
XT_BASE:
    .dw PFA_DOUSER
PFA_BASE:
.endif
    .dw USER_BASE
