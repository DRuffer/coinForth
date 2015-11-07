; ( xt1 xt2 -- ) 
; System
; does the real defer! for user based defers

.if cpu_msp430==1
    HEADER(XT_UDEFERSTORE,7,"Udefer!",DOCOLON)
.endif

.if cpu_avr8==1
VE_UDEFERSTORE:
    .dw $ff07
    .db "Udefer!",0
    .dw VE_HEAD
    .set VE_HEAD = VE_UDEFERSTORE
XT_UDEFERSTORE:
    .dw DO_COLON
PFA_UDEFERSTORE:
.endif

    .dw XT_FETCHI
    .dw XT_UP_FETCH
    .dw XT_PLUS
    .dw XT_STORE
    .dw XT_EXIT

