; ( n -- ) 
; System
; process the error prompt

.if cpu_msp430==1
    HEADLESS(XT_PROMPTERROR,DOCOLON)
    DW XT_DOSLITERAL
    DB 4," ?? " 
    .align 16
.endif

.if cpu_avr8==1
;VE_PROMPTERROR:
;    .dw $ff04
;    .db "p_er"
;    .dw VE_HEAD
;    .set VE_HEAD = VE_PROMPTERROR
XT_PROMPTERROR:
    .dw DO_COLON
PFA_PROMPTERROR:
	.dw XT_DOSLITERAL
    .dw 4
    .db " ?? "
.endif
    .dw XT_ITYPE
    .dw XT_BASE
    .dw XT_FETCH
    .dw XT_TO_R
    .dw XT_DECIMAL
    .dw XT_DOT
    .dw XT_TO_IN
    .dw XT_FETCH
    .dw XT_DOT
    .dw XT_R_FROM
    .dw XT_BASE
    .dw XT_STORE
    .dw XT_EXIT
