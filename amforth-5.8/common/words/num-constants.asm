.if cpu_msp430==1
    HEADER(XT_ZERO,1,"0",DOCON)
    DW 0
.endif

.if cpu_msp430==1
    HEADER(XT_ONE,1,"1",DOCON)
.endif

.if cpu_avr8==1
VE_ONE:
    .dw $ff01
    .db "1",0
    .dw VE_HEAD
    .set VE_HEAD = VE_ONE
XT_ONE:
    .dw PFA_DOVARIABLE
PFA_ONE:
.endif
        .DW 1

.if cpu_msp430==1
    HEADER(XT_TWO,1,"2",DOCON)
.endif

.if cpu_avr8==1
VE_TWO:
    .dw $ff01
    .db "2",0
    .dw VE_HEAD
    .set VE_HEAD = VE_TWO
XT_TWO:
    .dw PFA_DOVARIABLE
PFA_TWO:
.endif
        .DW 2
.if cpu_msp430==1
    HEADER(XT_MINUSONE,2,"-1",DOCON)
.endif

.if cpu_avr8==1
VE_MINUSONE:
    .dw $ff02
    .db "-1"
    .dw VE_HEAD
    .set VE_HEAD = VE_MINUSONE
XT_MINUSONE:
    .dw PFA_DOVARIABLE
PFA_MINUSONE:
.endif
        .DW -1
