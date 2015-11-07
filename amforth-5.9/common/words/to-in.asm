; ( -- a-addr ) 
; System Variable
; pointer to current read position in input buffer

.if cpu_msp430==1
    HEADER(XT_TO_IN,3,">in",DOUSER)
.endif

.if cpu_avr8==1
VE_TO_IN:
    .dw $ff03
    .db ">in",0
    .dw VE_HEAD
    .set VE_HEAD = VE_TO_IN
XT_TO_IN:
    .dw PFA_DOUSER
PFA_TO_IN:
.endif
    .dw USER_TO_IN
