; ( n1 n2 -- n3 ) 
; Arithmetics
; multiply routine

.if cpu_msp430==1
    HEADER(STAR,1,"*",DOCOLON)
.endif

.if cpu_avr8==1
VE_STAR:
    .dw $ff01
    .db "*",0
    .dw VE_HEAD
    .set VE_HEAD = VE_STAR
XT_STAR:
    .dw DO_COLON
PFA_STAR:
.endif

    .dw XT_MSTAR
    .dw XT_DROP
    .dw XT_EXIT
