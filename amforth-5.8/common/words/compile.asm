; ( -- ) 
; Dictionary
; read the following cell from the dictionary and append it to the current dictionary position.

.if cpu_msp430==1
    HEADER(XT_COMPILE,7,"compile",DOCOLON)
.endif

.if cpu_avr8==1
VE_COMPILE:
    .dw $ff07
    .db "compile",0
    .dw  VE_HEAD
    .set VE_HEAD = VE_COMPILE
XT_COMPILE:
    .dw DO_COLON
PFA_COMPILE:
.endif
    .dw XT_R_FROM
    .dw XT_DUP
.if cpu_msp430==1
    .dw XT_CELLPLUS
.endif
.if cpu_avr8==1
    .dw XT_1PLUS
.endif
    .dw XT_TO_R
    .dw XT_FETCHI
    .dw XT_COMMA
    .dw XT_EXIT
