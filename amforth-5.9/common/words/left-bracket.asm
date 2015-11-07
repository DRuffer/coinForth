; ( --  ) 
; Compiler
; enter interpreter mode

.if cpu_msp430==1
    IMMED(XT_LBRACKET,1,"[",DOCOLON)
.endif

.if cpu_avr8==1
VE_LBRACKET:
    .dw $0001
    .db "[",0
    .dw VE_HEAD
    .set VE_HEAD = VE_LBRACKET
XT_LBRACKET:
    .dw DO_COLON
PFA_LBRACKET:
.endif
    .dw XT_ZERO
    .dw XT_STATE
    .dw XT_STORE
    .dw XT_EXIT
