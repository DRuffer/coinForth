
.if cpu_msp430==1
    HEADER(XT_UDSTAR,3,"ud*",DOCOLON)
.endif

.if cpu_avr8==1
VE_UDSTAR:
    .dw $ff03
    .db "ud*"
    .dw VE_HEAD
    .set VE_HEAD = VE_UDSTAR
XT_UDSTAR:
    .dw DO_COLON
PFA_UDSTAR:

.endif
;Z UD*      ud1 d2 -- ud3      32*16->32 multiply
;   XT_DUP >R UM* DROP  XT_SWAP R> UM* ROT + ;

        .DW XT_DUP,XT_TO_R,XT_UMSTAR,XT_DROP
        .DW XT_SWAP,XT_R_FROM,XT_UMSTAR,XT_ROT,XT_PLUS,XT_EXIT
