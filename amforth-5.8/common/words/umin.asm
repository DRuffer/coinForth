
.if cpu_msp430==1
    HEADER(XT_UMIN,4,"umin",DOCOLON)
.endif

.if cpu_avr8==1
VE_UMIN:
    .dw $ff04
    .db "umin"
    .dw VE_HEAD
    .set VE_HEAD = VE_UMIN
XT_UMIN:
    .dw DO_COLON
PFA_UMIN:
.endif
        .DW XT_2DUP,XT_UGREATER
	.dw XT_DOCONDBRANCH
	DEST(UMIN1)
        .DW XT_SWAP
UMIN1:  .DW XT_DROP
	.dw XT_EXIT
