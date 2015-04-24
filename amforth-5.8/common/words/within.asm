; ( n min max -- f) 
; Compare
; check if n is within min..max

.if cpu_msp430==1
    HEADER(XT_WITHIN,6,"within",DOCOLON)
.endif

.if cpu_avr8==1
VE_WITHIN:
    .dw $ff06
    .db "within"
    .dw VE_HEAD
    .set VE_HEAD = VE_WITHIN
XT_WITHIN:
    .dw DO_COLON
PFA_WITHIN:
.endif
    .dw XT_OVER
    .dw XT_MINUS
    .dw XT_TO_R
    .dw XT_MINUS
    .dw XT_R_FROM
    .dw XT_ULESS
    .dw XT_EXIT
