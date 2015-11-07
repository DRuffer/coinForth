; ( x1 x2 -- x1 x2 x1 x2 ) 
; Stack
; Duplicate the 2 top elements

.if cpu_msp430==1
    HEADER(XT_2DUP,4,"2dup",DOCOLON)
.endif

.if cpu_avr8==1
VE_2DUP:
    .dw $ff04
    .db "2dup"
    .dw VE_HEAD
    .set VE_HEAD = VE_2DUP
XT_2DUP:
    .dw DO_COLON
PFA_2DUP:
.endif

    .dw XT_OVER
    .dw XT_OVER
    .dw XT_EXIT
