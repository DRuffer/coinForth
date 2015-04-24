; ( -- ) 
; Numeric IO
; initialize the pictured numeric output conversion process

.if cpu_msp430==1
    HEADER(XT_L_SHARP,2,"<#",DOCOLON)
.endif

.if cpu_avr8==1
VE_L_SHARP:
    .dw $ff02
    .db "<#"
    .dw VE_HEAD
    .set VE_HEAD = VE_L_SHARP
XT_L_SHARP:
    .dw DO_COLON
PFA_L_SHARP:
.endif
    .dw XT_PAD
    .dw XT_HLD
    .dw XT_STORE
    .dw XT_EXIT
