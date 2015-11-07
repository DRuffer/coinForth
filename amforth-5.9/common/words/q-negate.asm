;Z ?NEGATE  n1 n2 -- n3  negate n1 if n2 negative
;   0< IF NEGATE THEN ;        ...a common factor

.if cpu_msp430==1
    HEADER(XT_QNEGATE,7,"?negate",DOCOLON)
.endif

.if cpu_avr8==1
VE_QNEGATE:
    .dw $ff07
    .db "?negate"
    .dw VE_HEAD
    .set VE_HEAD = VE_QNEGATE
XT_QNEGATE:
    .dw DO_COLON
PFA_QNEGATE:

.endif
        DW XT_ZEROLESS,XT_DOCONDBRANCH
        DEST(QNEG1)
        DW XT_NEGATE
QNEG1:  DW XT_EXIT
