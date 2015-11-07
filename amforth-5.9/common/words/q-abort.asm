;Z ?ABORT   f c-addr u --      abort & print msg
;   ROT IF ITYPE ABORT THEN 2DROP ;

.if cpu_msp430==1
    HEADER(XT_QABORT,6,"?abort",DOCOLON)
.endif

.if cpu_avr8==1
VE_QABORT:
    .dw $ff06
    .db "?abort"
    .dw VE_HEAD
    .set VE_HEAD = VE_QABORT
XT_QABORT:
    .dw DO_COLON
PFA_QABORT:

.endif
        .DW XT_ROT,XT_DOCONDBRANCH
        DEST(QABO1)
        .DW XT_ITYPE,XT_ABORT
QABO1:  .DW XT_2DROP,XT_EXIT
