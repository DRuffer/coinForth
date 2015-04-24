; ( i*x -- ) (R: j*y -- )
; Exceptions
; send an exception -1
.if cpu_msp430==1
    HEADER(XT_ABORT,5,"abort",DOCOLON)
.endif

.if cpu_avr8==1
VE_ABORT:
    .dw $ff05
    .db "abort",0
    .dw VE_HEAD
    .set VE_HEAD = VE_ABORT
XT_ABORT:
    .dw DO_COLON
PFA_ABORT:
.endif
    .dw XT_DOLITERAL
    .dw -1
    .dw XT_THROW
