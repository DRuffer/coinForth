; ( xt1 xt2 -- ) 
; System
; The defer! for ram defers
.if cpu_msp430==1
    HEADER(XT_RDEFERSTORE,7,"Rdefer!",DOCOLON)
.endif

.if cpu_avr8==1
VE_RDEFERSTORE:
    .dw $ff07
    .db "Rdefer!",0
    .dw VE_HEAD
    .set VE_HEAD = VE_RDEFERSTORE
XT_RDEFERSTORE:
    .dw DO_COLON
PFA_RDEFERSTORE:
.endif
    .dw XT_FETCHI
    .dw XT_STORE
    .dw XT_EXIT

