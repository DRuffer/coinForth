; ( e-addr -- item-n .. item-1 n) 
; Tools
; Get a stack from EEPROM

.if cpu_msp430==1
    HEADER(XT_GET_STACK,9,"get-stack",DOCOLON)
.endif

.if cpu_avr8==1
VE_GET_STACK:
    .dw $ff09
    .db "get-stack",0
    .dw VE_HEAD
    .set VE_HEAD = VE_GET_STACK
XT_GET_STACK:
    .dw DO_COLON
PFA_N_FETCH_E:
.endif
    .dw XT_DUP
    .dw XT_CELLPLUS
    .dw XT_SWAP
    .dw XT_FETCHE
    .dw XT_DUP
    .dw XT_TO_R
    .dw XT_ZERO
    .dw XT_SWAP    ; go from bigger to smaller addresses
    .dw XT_QDOCHECK
    .dw XT_DOCONDBRANCH
    DEST(PFA_N_FETCH_E2)
    .dw XT_DODO
PFA_N_FETCH_E1:
    ; ( ee-addr )
    .dw XT_I
    .dw XT_1MINUS
    .dw XT_CELLS ; ( -- ee-addr i*2 )
    .dw XT_OVER  ; ( -- ee-addr i*2 ee-addr )
    .dw XT_PLUS  ; ( -- ee-addr ee-addr+i
    .dw XT_FETCHE ;( -- ee-addr item_i )
    .dw XT_SWAP   ;( -- item_i ee-addr )
    .dw XT_TRUE  ; shortcut for -1
    .dw XT_DOPLUSLOOP
    DEST(PFA_N_FETCH_E1)
PFA_N_FETCH_E2:
    .dw XT_2DROP
    .dw XT_R_FROM
    .dw XT_EXIT

