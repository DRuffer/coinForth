; ( "ccc<paren>" -- ) 
; Compiler
; skip everything up to the closing bracket on the same line

.if cpu_msp430==1
    IMMED(XT_PAREN,1,"(",DOCOLON)
.endif

.if cpu_avr8==1
VE_LPAREN:
    .dw $0001
    .db "(" ,0
    .dw VE_HEAD
    .set VE_HEAD = VE_LPAREN
XT_LPAREN:
    .dw DO_COLON
PFA_LPAREN:
.endif
    .dw XT_DOLITERAL
    .dw ')'
    .dw XT_PARSE
    .dw XT_2DROP
    .dw XT_EXIT
