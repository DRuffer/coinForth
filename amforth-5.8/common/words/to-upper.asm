; ( c -- C ) 
; String
; if c is a lowercase letter convert it to uppercase

.if cpu_msp430==1
    HEADER(XT_TOUPPER,7,"toupper",DOCOLON)
.endif

.if cpu_avr8==1
VE_TOUPPER:
    .dw $ff07 
    .db "toupper",0
    .dw VE_HEAD
    .set VE_HEAD = VE_TOUPPER
XT_TOUPPER:
    .dw DO_COLON 
PFA_TOUPPER:
.endif
    .dw XT_DUP 
    .dw XT_DOLITERAL 
    .dw 'a' 
    .dw XT_DOLITERAL 
    .dw 'z'+1
    .dw XT_WITHIN 
    .dw XT_DOCONDBRANCH
    DEST(PFA_TOUPPER0)
    .dw XT_DOLITERAL
    .dw 223 ; inverse of 0x20: 0xdf
    .dw XT_AND 
PFA_TOUPPER0:
    .dw XT_EXIT 
