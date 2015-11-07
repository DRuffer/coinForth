; ( -- ) 
; Numeric IO
; set base for numeric conversion to 10

.if cpu_msp430==1
    HEADER(XT_DECIMAL,7,"decimal",DOCOLON)
.endif

.if cpu_avr8==1
VE_DECIMAL:
    .dw $ff07
    .db "decimal",0
    .dw VE_HEAD
    .set VE_HEAD = VE_DECIMAL
XT_DECIMAL:
    .dw DO_COLON
PFA_DECIMAL:
.endif
    .dw XT_DOLITERAL
    .dw 10
    .dw XT_BASE
    .dw XT_STORE
    .dw XT_EXIT
