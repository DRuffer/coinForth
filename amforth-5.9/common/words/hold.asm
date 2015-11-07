; ( c -- ) 
; Numeric IO
; prepend character to pictured numeric output buffer

.if cpu_msp430==1
    HEADER(XT_HOLD,4,"hold",DOCOLON)
.endif

.if cpu_avr8==1
VE_HOLD:
    .dw $ff04
    .db "hold"
    .dw VE_HEAD
    .set VE_HEAD = VE_HOLD
XT_HOLD:
    .dw DO_COLON
PFA_HOLD:
.endif
    .dw XT_HLD
    .dw XT_DUP
    .dw XT_FETCH
    .dw XT_1MINUS
    .dw XT_DUP
    .dw XT_TO_R
    .dw XT_SWAP
    .dw XT_STORE
    .dw XT_R_FROM
    .dw XT_CSTORE
    .dw XT_EXIT
