; ( -- a-addr ) 
; Exceptions
; USER variable used by catch/throw

.if cpu_msp430==1
    HEADER(XT_HANDLER,7,"handler",DOUSER)
.endif

.if cpu_avr8==1
VE_HANDLER:
    .dw $ff07
    .db "handler",0
    .dw VE_HEAD
    .set VE_HEAD = VE_HANDLER
XT_HANDLER:
    .dw PFA_DOUSER
PFA_HANDLER:
.endif
    .dw USER_HANDLER
