; ( xt1 -- xt2 ) 
; System
; does the real defer@ for user based defers

.if cpu_msp430==1
    HEADER(XT_UDEFERFETCH,7,"Udefer@",DOCOLON)
.endif

.if cpu_avr8==1
VE_UDEFERFETCH:
    .dw $ff07
    .db "Udefer@",0
    .dw VE_HEAD
    .set VE_HEAD = VE_UDEFERFETCH
XT_UDEFERFETCH:
    .dw DO_COLON
PFA_UDEFERFETCH:
.endif
    .dw XT_FETCHI
    .dw XT_UP_FETCH
    .dw XT_PLUS
    .dw XT_FETCH
    .dw XT_EXIT
