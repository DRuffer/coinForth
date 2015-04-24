; ( n -- ) 
; Numeric IO
; place a - in HLD if n is negative

.if cpu_msp430==1
    HEADER(XT_SIGN,4,"sign",DOCOLON)
.endif

.if cpu_avr8==1
VE_SIGN:
    .dw $ff04
    .db "sign"
    .dw VE_HEAD
    .set VE_HEAD = VE_SIGN
XT_SIGN:
    .dw DO_COLON
PFA_SIGN:
.endif
    .dw XT_ZEROLESS
    .dw XT_DOCONDBRANCH
    DEST(PFA_SIGN1)
    .dw XT_DOLITERAL
    .dw 45 ; ascii -
    .dw XT_HOLD
PFA_SIGN1:
    .dw XT_EXIT
