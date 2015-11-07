; ( n -- ) 
; Numeric IO
; singed PNO with single cell numbers

.if cpu_msp430==1
    HEADER(XT_DOT,1,".",DOCOLON)
.endif

.if cpu_avr8==1


VE_DOT:
    .dw $ff01
    .db ".",0
    .dw VE_HEAD
    .set VE_HEAD = VE_DOT
XT_DOT:
    .dw DO_COLON
PFA_DOT:
.endif
    .dw XT_S2D
    .dw XT_DDOT
    .dw XT_EXIT
; : .         ( s -- )    s>d d. ; 
