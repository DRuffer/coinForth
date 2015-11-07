; ( -- n ) (C: n -- )
; Compiler
; compile a literal in colon defintions

.if cpu_msp430==1
    IMMED(XT_LITERAL,7,"literal",DOCOLON)
.endif

.if cpu_avr8==1
VE_LITERAL:
    .dw $0007
    .db "literal",0
    .dw VE_HEAD
    .set VE_HEAD = VE_LITERAL
XT_LITERAL:
    .dw DO_COLON
PFA_LITERAL:
.endif
        .DW XT_COMPILE
        .DW XT_DOLITERAL
        .DW XT_COMMA
        .DW XT_EXIT
