; ( --  ) 
; Compiler
; enter compiler mode

.if cpu_msp430==1
    HEADER(XT_RBRACKET,1,"]",DOCOLON)
.endif

.if cpu_avr8==1
VE_RBRACKET:
    .dw $ff01
    .db "]",0
    .dw VE_HEAD
    .set VE_HEAD = VE_RBRACKET
XT_RBRACKET:
    .dw DO_COLON
PFA_RBRACKET:
.endif
    .dw XT_DOLITERAL
    .dw 1
    .dw XT_STATE
    .dw XT_STORE
    .dw XT_EXIT
