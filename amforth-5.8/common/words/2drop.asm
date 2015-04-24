; ( x1 x2 --  ) 
; Stack
; Remove the 2 top elements

.if cpu_msp430==1
    HEADER(XT_2DROP,5,"2drop",DOCOLON)
.endif

.if cpu_avr8==1
VE_2DROP:
    .dw $ff05
    .db "2drop",0
    .dw VE_HEAD
    .set VE_HEAD = VE_2DROP
XT_2DROP:
    .dw DO_COLON
PFA_2DROP:
.endif
    .dw XT_DROP
    .dw XT_DROP
    .dw XT_EXIT
