
.if cpu_msp430==1
    HEADER(XT_UMAX,4,"umax",DOCOLON)
.endif

.if cpu_avr8==1
VE_UMAX:
    .dw $ff04
    .db "umax"
    .dw VE_HEAD
    .set VE_HEAD = VE_UMAX
XT_UMAX:
    .dw DO_COLON
PFA_UMAX:
.endif

        .DW XT_2DUP,XT_ULESS
	.dw XT_DOCONDBRANCH
	 DEST(UMAX1)
        .DW XT_SWAP
UMAX1:  .DW XT_DROP
	.dw XT_EXIT
