; ( widn .. wid-1 n -- ) 
; Search Order
; replace the search order list

.if cpu_msp430==1
    HEADER(XT_SET_ORDER,9,"set-order",DOCOLON)
.endif

.if cpu_avr8==1
VE_SET_ORDER:
    .dw $ff09
    .db "set-order",0
    .dw VE_HEAD
    .set VE_HEAD = VE_SET_ORDER
XT_SET_ORDER:
    .dw DO_COLON
PFA_SET_ORDER:
.endif
    .dw XT_DOLITERAL
    .dw CFG_ORDERLISTLEN
    .dw XT_SET_STACK
    .dw XT_EXIT

