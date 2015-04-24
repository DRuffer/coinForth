; ( -- rec-n .. rec-1 n) 
; Interpreter
; Get the current recognizer list

.if cpu_msp430==1
    HEADER(XT_GET_RECOGNIZERS,15,"get-recognizers",DOCOLON)
.endif

.if cpu_avr8==1
VE_GET_RECOGNIZERS:
    .dw $ff0f
    .db "get-recognizers",0
    .dw VE_HEAD
    .set VE_HEAD = VE_GET_RECOGNIZERS
XT_GET_RECOGNIZERS:
    .dw DO_COLON
PFA_GET_RECOGNIZERS:
.endif
    .dw XT_DOLITERAL
    .dw CFG_RECOGNIZERLISTLEN
    .dw XT_GET_STACK
    .dw XT_EXIT
