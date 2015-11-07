; ( nt -- xt )
; Tools (ext)
; get the execution token from the name token
.if cpu_msp430==1
    HEADER(XT_NAME2INTERPRET,14,"name>interpret",DOCOLON)
.endif

.if cpu_avr8==1
VE_NAME2INTERPRET:
    .dw $ff0e
    .db "name>interpret"
    .dw VE_HEAD
    .set VE_HEAD = VE_NAME2INTERPRET
XT_NAME2INTERPRET:
    .dw DO_COLON
PFA_NAME2INTERPRET:
.endif
    .dw XT_NFA2CFA
    .dw XT_EXIT
