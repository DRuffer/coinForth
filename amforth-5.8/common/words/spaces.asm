; ( n -- ) 
; Character IO
; emits n space(s) (bl)

.if cpu_msp430==1
    HEADER(XT_SPACES,6,"spaces",DOCOLON)
.endif

.if cpu_avr8==1
VE_SPACES:
    .dw $ff06
    .db "spaces"
    .dw VE_HEAD
    .set VE_HEAD = VE_SPACES
XT_SPACES:
    .dw DO_COLON
PFA_SPACES:

.endif
;C SPACES   n --            output n spaces
;   BEGIN DUP 0> WHILE SPACE 1- REPEAT DROP ;
	.DW XT_ZERO, XT_MAX
SPCS1:  .DW XT_DUP,XT_DOCONDBRANCH
        DEST(SPCS2)
        .DW XT_SPACE,XT_1MINUS,XT_DOBRANCH
        DEST(SPCS1)
SPCS2:  .DW XT_DROP,XT_EXIT
