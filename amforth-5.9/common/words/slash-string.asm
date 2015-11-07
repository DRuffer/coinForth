; ( addr1 u1 n -- addr2 u2 ) 
; String
; adjust string from addr1 to addr1+n, reduce length from u1 to u2 by n

.if cpu_msp430==1
    HEADER(XT_SLASHSTRING,7,"/string",DOCOLON)
.endif

.if cpu_avr8==1
VE_SLASHSTRING:
    .dw $ff07
    .db "/string",0
    .dw VE_HEAD
    .set VE_HEAD = VE_SLASHSTRING
XT_SLASHSTRING:
    .dw DO_COLON
PFA_SLASHSTRING:
.endif
    .dw XT_ROT
    .dw XT_OVER
    .dw XT_PLUS
    .dw XT_ROT
    .dw XT_ROT
    .dw XT_MINUS
    .dw XT_EXIT

