; ( -- 32 ) 
; Character IO
; put ascii code of the blank to the stack

.if cpu_msp430==1
    HEADER(XT_BL,2,"bl",DOCON)
.endif

.if cpu_avr8==1
VE_BL:
    .dw $ff02
    .db "bl"
    .dw VE_HEAD
    .set VE_HEAD = VE_BL
XT_BL:
    .dw PFA_DOVARIABLE
PFA_BL:
.endif
    .dw 32
