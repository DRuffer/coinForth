; ( -- faddr len ) 
; Environment
; flash address of the CPU identification string

.if cpu_msp430==1
    ENVIRONMENT(XT_ENV_CPU,3,"cpu")
    .dw XT_DOSLITERAL
    .db 11,"MSP430G2553" 
    .dw XT_EXIT
.endif

.if cpu_avr8==1
VE_ENV_CPU:
    .dw $ff03
    .db "cpu",0
    .dw VE_ENVHEAD
    .set VE_ENVHEAD = VE_ENV_CPU
XT_ENV_CPU:
    .dw DO_COLON
PFA_EN_CPU:
    .dw XT_DOLITERAL
    .dw mcu_name
    .dw XT_ICOUNT
.endif
    .dw XT_EXIT
