; ( n1 n2 -- n3) 
; Arithmetics
; divide n1 by n2. giving the quotient

.if cpu_msp430==1
    HEADER(SLASH,1,"/",DOCOLON)
.endif

.if cpu_avr8==1


VE_SLASH:
    .dw $ff01
    .db "/",0
    .dw VE_HEAD
    .set VE_HEAD = VE_SLASH
XT_SLASH:
    .dw DO_COLON
PFA_SLASH:
.endif
    .dw XT_SLASHMOD
    .dw XT_NIP
    .dw XT_EXIT

