; ( -- n )
; Environment
; version number of amforth
.if cpu_msp430==1
    ENVIRONMENT(XT_ENV_FORTHVERSION,7,"version")
.endif

.if cpu_avr8==1
VE_ENV_FORTHVERSION:
    .dw $ff07
    .db "version",0
    .dw VE_ENVHEAD
    .set VE_ENVHEAD = VE_ENV_FORTHVERSION
XT_ENV_FORTHVERSION:
    .dw DO_COLON
PFA_EN_FORTHVERSION:
.endif
    .dw XT_DOLITERAL
    .dw 58
    .dw XT_EXIT
