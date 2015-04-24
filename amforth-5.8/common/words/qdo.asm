; ( n1|u1 n2|u2 -- ) R( -- | loop-sys ) (C: -- do-sys)
; Compiler
; start a ?do .. [+]loop control structure

.if cpu_msp430==1
    IMMED(XT_QDO,3,"?do",DOCOLON)
.endif

.if cpu_avr8==1

VE_QDO:
    .dw $0003
    .db "?do",0
    .dw VE_HEAD
    .set VE_HEAD = VE_QDO
XT_QDO:
    .dw DO_COLON
PFA_QDO:
.endif
    .dw XT_COMPILE
    .dw XT_QDOCHECK
    .dw XT_IF
    .dw XT_DO
    .dw XT_SWAP    ; DO sets a 0 marker on the leave stack
    .dw XT_TO_L    ; then follows at the end.
    .dw XT_EXIT

; there is no special runtime for ?do, the do runtime
; gets wrapped with the sequence
; ... ?do-check if do ..... loop then
; with
; : ?do-check ( n1 n2 -- n1 n2 true | false )
;   2dup = dup >r if 2drop then r> invert ;

.if cpu_msp430==1
    HEADLESS(XT_QDOCHECK,DOCOLON)
.endif

.if cpu_avr8==1
XT_QDOCHECK:
    .dw DO_COLON
PFA_QDOCHECK:
.endif
    .dw XT_2DUP
    .dw XT_EQUAL
    .dw XT_DUP
    .dw XT_TO_R
    .dw XT_DOCONDBRANCH
    DEST(PFA_QDOCHECK1)
    .dw XT_2DROP
PFA_QDOCHECK1:
    .dw XT_R_FROM
    .dw XT_INVERT
    .dw XT_EXIT
