; ( u -- ) 
; Numeric IO
; unsigned PNO with single cell numbers

.if cpu_msp430==1
    HEADER(XT_UDOT,2,"u.",DOCOLON)
.endif

.if cpu_avr8==1
VE_UDOT:
    .dw $ff02
    .db "u."
    .dw VE_HEAD
    .set VE_HEAD = VE_UDOT
XT_UDOT:
    .dw DO_COLON
PFA_UDOT:
.endif
    .dw XT_ZERO
    .dw XT_UDDOT
    .dw XT_EXIT
; : u.        ( us -- )    0 ud. ;
