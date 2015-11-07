; ( n -- ) 
; System
; process the error prompt

.if cpu_msp430==1
   HEADLESS(XT_PROMPTREADY,DOCOLON)
    DW XT_DOSLITERAL
    DB 2,"> " 
    .align 16
.endif

.if cpu_avr8==1
;VE_PROMPTRDY:
;    .dw $ff04
;    .db "p_er"
;    .dw VE_HEAD
;    .set VE_HEAD = VE_PROMPTRDY
XT_PROMPTREADY:
    .dw DO_COLON
PFA_PROMPTREADY:
    .dw XT_DOSLITERAL
    .dw 2
    .db "> "
.endif
    .dw XT_CR
    .dw XT_ITYPE
    .dw XT_EXIT
