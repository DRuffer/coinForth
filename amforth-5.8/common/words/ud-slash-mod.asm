; ( d1 n -- rem ud2 ) 
; Arithmetics
; unsigned double cell division with remainder

.if cpu_msp430==1
    HEADER(XT_UDSLASHMOD,6,"ud/mod",DOCOLON)
.endif

.if cpu_avr8==1
VE_UDSLASHMOD:
    .dw $ff06
    .db "ud/mod"
    .dw VE_HEAD
    .set VE_HEAD = VE_UDSLASHMOD
XT_UDSLASHMOD:
    .dw DO_COLON
PFA_UDSLASHMOD:
.endif
    .dw XT_TO_R
    .dw XT_ZERO
    .dw XT_R_FETCH
    .dw XT_UMSLASHMOD
    .dw XT_R_FROM
    .dw XT_SWAP
    .dw XT_TO_R
    .dw XT_UMSLASHMOD
    .dw XT_R_FROM
    .dw XT_EXIT
