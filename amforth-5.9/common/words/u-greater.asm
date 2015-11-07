; ( u1 u2 -- flag ) 
; Compare
; true if u1 > u2 (unsigned)

.if cpu_msp430==1
        HEADER(XT_UGREATER,2,"u>",DOCOLON)
.endif

.if cpu_avr8==1
VE_UGREATER:
    .dw $ff02
    .db "u>"
    .dw VE_HEAD
    .set VE_HEAD = VE_UGREATER
XT_UGREATER:
    .dw DO_COLON
PFA_UGREATER:
.endif
    .DW XT_SWAP
    .dw XT_ULESS
    .dw XT_EXIT
