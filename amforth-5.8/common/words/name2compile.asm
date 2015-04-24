; ( nt -- xt1 xt2 )
; Tools (ext)
; get the execution token from the name token in compile state
.if cpu_msp430==1
    HEADER(XT_NAME2COMPILE,12,"name>compile",DOCOLON)
.endif

.if cpu_avr8==1
VE_NAME2COMPILE:
    .dw $ff0c
    .db "name>compile"
    .dw VE_HEAD
    .set VE_HEAD = VE_NAME2COMPILE
XT_NAME2COMPILE:
    .dw DO_COLON
PFA_NAME2COMPILE:
.endif
    .dw XT_DUP
    .dw XT_NFA2CFA
    .dw XT_SWAP
    .dw XT_NAME2FLAGS
    .dw XT_IMMEDIATEQ
    .dw XT_DOCONDBRANCH
    DEST(NAME2COMPILE1)
	.dw XT_DOLITERAL
	.dw XT_COMMA
	.dw XT_EXIT
NAME2COMPILE1:
	.dw XT_DOLITERAL
	.dw XT_EXECUTE
    .dw XT_EXIT
