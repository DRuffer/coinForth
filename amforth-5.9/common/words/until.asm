; ( f -- ) (C: dest -- ) 
; Compiler
; finish begin with conditional branch, leaves the loop if true flag at runtime

.if cpu_msp430==1
    IMMED(XT_UNTIL,5,"until",DOCOLON)
.endif

.if cpu_avr8==1
VE_UNTIL:
    .dw $0005
    .db "until",0
    .dw VE_HEAD
    .set VE_HEAD = VE_UNTIL
XT_UNTIL:
    .dw DO_COLON
PFA_UNTIL:
.endif
    .dw XT_DOLITERAL
    .dw XT_DOCONDBRANCH
    .dw XT_COMMA

    .dw XT_LRESOLVE
    .dw XT_EXIT
