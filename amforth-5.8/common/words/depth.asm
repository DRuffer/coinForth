; ( -- n ) 
; Stack
; number of single-cell values contained in the data stack before n was placed on the stack.
.if cpu_msp430==1
    HEADER(XT_DEPTH,5,"depth",DOCOLON)
.endif

.if cpu_avr8==1
VE_DEPTH:
    .dw $ff05
    .db "depth",0
    .dw VE_HEAD
    .set VE_HEAD = VE_DEPTH
XT_DEPTH:
    .dw DO_COLON
PFA_DEPTH:
.endif
    .dw XT_SP0
    .dw XT_SP_FETCH
    .dw XT_MINUS
    .dw XT_2SLASH
    .dw XT_1MINUS
    .dw XT_EXIT
