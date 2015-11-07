; ( -- ) 
; Character IO
; cause subsequent output appear at the beginning of the next line

.if cpu_msp430==1
    HEADER(XT_CR,2,"cr",DOCOLON)
.endif

.if cpu_avr8==1
VE_CR:
    .dw 0xff02
    .db "cr"
    .dw VE_HEAD
    .set VE_HEAD = VE_CR
XT_CR:
    .dw DO_COLON
PFA_CR:
.endif

    .dw XT_DOLITERAL
    .dw 13
    .dw XT_EMIT
    .dw XT_DOLITERAL
    .dw 10
    .dw XT_EMIT
    .dw XT_EXIT
