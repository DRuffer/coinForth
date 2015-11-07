; ( -- d ) 
; System
; put the cpu frequency in Hz on stack
.if cpu_msp430==1
    HEADER(XT_F_CPU,5,"f_cpu",DOCOLON)
.endif

.if cpu_avr8==1
VE_F_CPU:
    .dw $ff05
    .db "f_cpu",0
    .dw VE_HEAD
    .set VE_HEAD = VE_F_CPU
XT_F_CPU:
    .dw DO_COLON
PFA_F_CPU:
.endif
    .dw XT_DOLITERAL
    .dw (F_CPU % 65536)
    .dw XT_DOLITERAL
    .dw (F_CPU / 65536)
    .dw XT_EXIT
