; ( d -- ) 
; Numeric IO
; singed PNO with double cell numbers

.if cpu_msp430==1
    HEADER(XT_DDOT,2,"d.",DOCOLON)
.endif

.if cpu_avr8==1
VE_DDOT:
    .dw $ff02
    .db "d."
    .dw VE_HEAD
    .set VE_HEAD = VE_DDOT
XT_DDOT:
    .dw DO_COLON
PFA_DDOT:

.endif
    .dw XT_ZERO
    .dw XT_DDOTR
    .dw XT_SPACE
    .dw XT_EXIT
; : d.        ( d -- )    0 d.r space ;
