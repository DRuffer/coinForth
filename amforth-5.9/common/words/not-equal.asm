; ( n1 n2 -- flag) 
; Compare
; true if n1 is not equal to n2

.if cpu_msp430==1
    HEADER(XT_NOTEQUAL,2,"<>",DOCOLON)
.endif

.if cpu_avr8==1
VE_NOTEQUAL:
    .dw $ff02
    .db "<>"
    .dw VE_HEAD
    .set VE_HEAD = VE_NOTEQUAL
XT_NOTEQUAL:
    .dw DO_COLON
PFA_NOTEQUAL:
.endif

    .DW XT_EQUAL,XT_ZEROEQUAL,XT_EXIT
