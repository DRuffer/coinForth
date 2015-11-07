; ( -- ) 
; Numeric IO
; set base for numeric conversion to 10

.if cpu_msp430==1
    HEADER(XT_HEX,3,"hex",DOCOLON)
.endif

.if cpu_avr8==1
VE_HEX:
    .dw $ff03
    .db "hex",0
    .dw VE_HEAD
    .set VE_HEAD = VE_HEX
XT_HEX:
    .dw DO_COLON
PFA_HEX:
.endif
    .dw XT_DOLITERAL
    .dw 16
    .dw XT_BASE
    .dw XT_STORE
    .dw XT_EXIT
