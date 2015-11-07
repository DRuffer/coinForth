; ( -- x ) (C: x "<spaces>name" -- )
; Compiler
; create a constant in the dictionary

.if cpu_msp430==1
    HEADER(XT_CONSTANT,8,"constant",DOCOLON)
.endif

.if cpu_avr8==1

VE_CONSTANT:
    .dw $ff08
    .db "constant"
    .dw VE_HEAD
    .set VE_HEAD = VE_CONSTANT
XT_CONSTANT:
    .dw DO_COLON
PFA_CONSTANT:
.endif
    .dw XT_DOCREATE
    .dw XT_REVEAL
    .dw XT_COMPILE
    .dw PFA_DOVARIABLE
    .dw XT_COMMA
    .dw XT_EXIT
