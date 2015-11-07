; ( cchar -- ) 
; Compiler
; create a dictionary entry for a variable and allocate 1 cell RAM

.if cpu_msp430==1
    HEADER(VARIABLE,8,"variable",DOCOLON)
.endif

.if cpu_avr8==1

VE_VARIABLE:
    .dw $ff08
    .db "variable"
    .dw VE_HEAD
    .set VE_HEAD = VE_VARIABLE
XT_VARIABLE:
    .dw DO_COLON
PFA_VARIABLE:
.endif
    .dw XT_HERE
    .dw XT_CONSTANT
    .dw XT_DOLITERAL
    .dw 2
    .dw XT_ALLOT
    .dw XT_EXIT
