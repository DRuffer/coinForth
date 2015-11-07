; ( c -- (number|) flag ) 
; Numeric IO
; tries to convert a character to a number, set flag accordingly

.if cpu_msp430==1
    HEADER(XT_DIGITQ,6,"digit?",DOCOLON)
.endif

.if cpu_avr8==1
VE_DIGITQ:
    .dw $ff06 
    .db "digit?"
    .dw VE_HEAD
    .set VE_HEAD = VE_DIGITQ
XT_DIGITQ:
    .dw DO_COLON 
PFA_DIGITQ:
.endif
    .dw XT_TOUPPER
    .DW XT_DUP,XT_DOLITERAL,57,XT_GREATER,XT_DOLITERAL,256
    .DW XT_AND,XT_PLUS,XT_DUP,XT_DOLITERAL,320,XT_GREATER
    .DW XT_DOLITERAL,263,XT_AND,XT_MINUS,XT_DOLITERAL,48
    .DW XT_MINUS,XT_DUP,XT_BASE,XT_FETCH,XT_ULESS
    .DW XT_EXIT
