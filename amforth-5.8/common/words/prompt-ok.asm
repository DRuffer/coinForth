; ( -- )
; System
; send the READY prompt to the command line

.if cpu_msp430==1
    HEADLESS(XT_PROMPTOK,DOCOLON)
    DW XT_DOSLITERAL
    DB 3," ok" 
.endif

.if cpu_avr8==1
;VE_PROMPTOK:
;    .dw $ff02
;    .db "ok"
;    .dw VE_HEAD
;    .set VE_HEAD = VE_PROMPTOK
XT_PROMPTOK:
    .dw DO_COLON
PFA_PROMPTOK:
    .dw XT_DOSLITERAL
    .dw 3
    .db " ok",0
.endif
    .dw XT_ITYPE
    .dw XT_EXIT
