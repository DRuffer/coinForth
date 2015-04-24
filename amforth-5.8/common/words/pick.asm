
.if cpu_msp430==1
    HEADER(XT_PICK,4,"pick",DOCOLON)
.endif

.if cpu_avr8==1
VE_PICK:
    .dw $ff04
    .db "pick"
    .dw VE_HEAD
    .set VE_HEAD = VE_PICK
XT_PICK:
    .dw DO_COLON
PFA_PICK:
.endif
    .dw XT_1PLUS
    .dw XT_CELLS
    .dw XT_SP_FETCH
    .dw XT_PLUS
    .dw XT_FETCH
    .dw XT_EXIT
