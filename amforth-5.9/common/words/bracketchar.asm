; ( -- c ) (C: "<space>name" -- )
; Tools
; skip leading space delimites, place the first character of the word on the stack

.if cpu_msp430==1
    IMMED(XT_BRACKETCHAR,6,"[char]",DOCOLON)
.endif

.if cpu_avr8==1
VE_BRACKETCHAR:
    .dw $0006
    .db "[char]"
    .dw VE_HEAD
    .set VE_HEAD = VE_BRACKETCHAR
XT_BRACKETCHAR:
    .dw DO_COLON
PFA_BRACKETCHAR:
.endif
    .dw XT_COMPILE
    .dw XT_DOLITERAL
    .dw XT_CHAR
    .dw XT_COMMA
    .dw XT_EXIT
