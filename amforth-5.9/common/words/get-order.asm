; ( -- wid-n .. wid-1 n) 
; Search Order
; Get the current search order word list

.if cpu_msp430==1
    HEADER(XT_GET_ORDER,9,"get-order",DOCOLON)
.endif

.if cpu_avr8==1
VE_GET_ORDER:
    .dw $ff09
    .db "get-order",0
    .dw VE_HEAD
    .set VE_HEAD = VE_GET_ORDER
XT_GET_ORDER:
    .dw DO_COLON
PFA_GET_ORDER:
.endif
    .dw XT_DOLITERAL
    .dw CFG_ORDERLISTLEN
    .dw XT_GET_STACK
    .dw XT_EXIT
