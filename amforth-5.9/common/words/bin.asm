; ( -- ) 
; Numeric IO
; set base for numeric conversion to 10

.if cpu_msp430==1
    HEADER(XT_BIN,3,"bin",DOCOLON)
.endif

.if cpu_avr8==1
VE_BIN:
    .dw $ff03
    .db "bin",0
    .dw VE_HEAD
    .set VE_HEAD = VE_BIN
XT_BIN:
    .dw DO_COLON
PFA_BIN:
.endif
    .dw XT_DOLITERAL
    .dw 2
    .dw XT_BASE
    .dw XT_STORE
    .dw XT_EXIT
