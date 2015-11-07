; ( n1 n2 -- ) (R: -- loop-sys ) (C: -- do-sys )
; Compiler
; start do .. [+]loop

.if cpu_msp430==1
    IMMED(XT_DO,2,"do",DOCOLON)
.endif

.if cpu_avr8==1
VE_DO:
    .dw $0002
    .db "do"
    .dw VE_HEAD
    .set VE_HEAD = VE_DO
XT_DO:
    .dw DO_COLON
PFA_DO:

.endif
    .dw XT_COMPILE
    .dw XT_DODO
    .dw XT_LMARK
    .dw XT_ZERO
    .dw XT_TO_L
    .dw XT_EXIT
