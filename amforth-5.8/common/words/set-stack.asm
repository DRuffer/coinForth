; ( rec-n .. rec-1 n ee-addr -- ) 
; Tools
; Write a stack to EEPROM
.if cpu_msp430==1
    HEADER(XT_SET_STACK,9,"set-stack",DOCOLON)
.endif

.if cpu_avr8==1
VE_SET_STACK:
    .dw $ff09
    .db "set-stack",0
    .dw VE_HEAD
    .set VE_HEAD = VE_SET_STACK
XT_SET_STACK:
    .dw DO_COLON
PFA_SET_STACK:
.endif
    .dw XT_2DUP
    .dw XT_STOREE ; ( -- i_n .. i_0 n e-addr )
    .dw XT_SWAP    
    .dw XT_ZERO
    .dw XT_QDOCHECK
    .dw XT_DOCONDBRANCH
    DEST(PFA_SET_STACK2)
    .dw XT_DODO
PFA_SET_STACK1:
    .dw XT_CELLPLUS ; ( -- i_x e-addr )
    .dw XT_TUCK      ; ( -- e-addr i_x e-addr
    .dw XT_STOREE
    .dw XT_DOLOOP
    DEST(PFA_SET_STACK1)
PFA_SET_STACK2:
    .dw XT_DROP
    .dw XT_EXIT

