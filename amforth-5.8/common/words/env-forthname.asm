; ( -- faddr len ) 
; Environment
; flash address of the amforth name string
.if cpu_msp430==1
    ENVIRONMENT(XT_ENV_FORTHNAME,10,"forth-name")
    .dw XT_DOSLITERAL
    .db 7
.endif

.if cpu_avr8==1
VE_ENV_FORTHNAME:
    .dw $ff0a
    .db "forth-name"
    .dw VE_ENVHEAD
    .set VE_ENVHEAD = VE_ENV_FORTHNAME
XT_ENV_FORTHNAME:
    .dw DO_COLON
PFA_EN_FORTHNAME:
    .dw XT_DOSLITERAL
    .dw 7
.endif
    .db "amforth"
.if cpu_msp430==1
    .align 16
.endif
    .dw XT_EXIT
