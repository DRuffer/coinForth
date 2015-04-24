; ( n1 -- d1 ) 
; Conversion
; extend (signed) single cell value to double cell
.if cpu_msp430==1
    HEADER(XT_S2D,3,"s>d",DOCOLON)
.endif

.if cpu_avr8==1
VE_S2D:
    .dw $ff03
    .db "s>d",0
    .dw VE_HEAD
    .set VE_HEAD = VE_S2D
XT_S2D:
    .dw DO_COLON
PFA_S2D:
.endif
    .dw XT_DUP
    .dw XT_ZEROLESS
    .dw XT_EXIT
