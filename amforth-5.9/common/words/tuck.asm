; ( n1 n2 -- n2 n1 n2 ) 
; Stack
; Copy the first (top) stack item below the second stack item. 

.if cpu_msp430==1
    HEADER(XT_TUCK,4,"tuck",DOCOLON)
.endif

.if cpu_avr8==1
VE_TUCK:
    .dw $ff04
    .db "tuck"
    .dw VE_HEAD
    .set VE_HEAD = VE_TUCK
XT_TUCK:
    .dw DO_COLON
PFA_TUCK:
.endif
    .dw XT_SWAP
    .dw XT_OVER
    .dw XT_EXIT
