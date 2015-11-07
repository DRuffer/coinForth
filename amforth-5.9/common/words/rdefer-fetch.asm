; ( xt1 -- xt2 ) 
; System
; The defer@ for ram defers
.if cpu_msp430==1
    HEADER(XT_RDEFERFETCH,7,"Rdefer@",DOCOLON)
.endif

.if cpu_avr8==1
VE_RDEFERFETCH:
    .dw $ff07
    .db "Rdefer@",0
    .dw VE_HEAD
    .set VE_HEAD = VE_RDEFERFETCH
XT_RDEFERFETCH:
    .dw DO_COLON
PFA_RDEFERFETCH:
.endif
    .dw XT_FETCHI
    .dw XT_FETCH
    .dw XT_EXIT
