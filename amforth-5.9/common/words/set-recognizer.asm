; ( rec-n .. rec-1 n -- ) 
; Interpreter
; replace the recognizer list

.if cpu_msp430==1
    HEADER(XT_SET_RECOGNIZERS,15,"set-recognizers",DOCOLON)
.endif

.if cpu_avr8==1
VE_SET_RECOGNIZERS:
    .dw $ff0f
    .db "set-recognizers",0
    .dw VE_HEAD
    .set VE_HEAD = VE_SET_RECOGNIZERS
XT_SET_RECOGNIZERS:
    .dw DO_COLON
PFA_SET_RECOGNIZERS:
.endif
    .dw XT_DOLITERAL
    .dw CFG_RECOGNIZERLISTLEN
    .dw XT_SET_STACK
    .dw XT_EXIT

