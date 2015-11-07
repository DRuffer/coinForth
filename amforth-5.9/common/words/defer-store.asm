; ( xt1 xt2 -- ) 
; System
; stores xt1 as the xt to be executed when xt2 is called

.if cpu_msp430==1
    HEADER(XT_DEFERSTORE,6,"defer!",DOCOLON)
.endif

.if cpu_avr8==1
VE_DEFERSTORE:
    .dw $ff06
    .db "defer!"
    .dw VE_HEAD
    .set VE_HEAD = VE_DEFERSTORE
XT_DEFERSTORE:
    .dw DO_COLON
PFA_DEFERSTORE:
.endif
    .dw XT_TO_BODY
    .dw XT_DUP
    .dw XT_ICELLPLUS
    .dw XT_ICELLPLUS
    .dw XT_FETCHI
    .dw XT_EXECUTE
    .dw XT_EXIT

