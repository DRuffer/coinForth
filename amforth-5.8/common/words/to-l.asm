
.if cpu_msp430==1
    HEADER(XT_TO_L,2,">l",DOCOLON)
.endif

.if cpu_avr8==1
VE_TO_L:
    .dw $ff02
    .db ">l"
    .dw VE_HEAD
    .set VE_HEAD = VE_TO_L
XT_TO_L:
    .dw DO_COLON
PFA_TO_L:
.endif
;Z >L   x --   L: -- x        move to leave stack
;   CELL LP +!  LP @ ! ;      (L stack grows up)

        .dw XT_DOLITERAL
	.dw 2
	.dw XT_LP
	.dw XT_PLUSSTORE
	.dw XT_LP
	.dw XT_FETCH
	.dw XT_STORE
	.dw XT_EXIT
