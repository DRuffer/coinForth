;Z ?DNEGATE  d1 n -- d2   negate d1 if n negative
;   0< IF DNEGATE THEN ;       ...a common factor

.if cpu_msp430==1
    HEADER(XT_QDNEGATE,8,"?dnegate",DOCOLON)
.endif

.if cpu_avr8==1
VE_QDNEGATE:
    .dw $ff08
    .db "?dnegate"
    .dw VE_HEAD
    .set VE_HEAD = VE_QDNEGATE
XT_QDNEGATE:
    .dw DO_COLON
PFA_QDNEGATE:
.endif
        DW XT_ZEROLESS,XT_DOCONDBRANCH
        DEST(DNEG1)
        DW XT_DNEGATE
DNEG1:  DW XT_EXIT
