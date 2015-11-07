; ( xt1 -- xt2 ) 
; System
; returns the XT associated with the given XT

.if cpu_msp430==1
    HEADER(XT_DEFERFETCH,6,"defer@",DOCOLON)
.endif

.if cpu_avr8==1
VE_DEFERFETCH:
    .dw $ff06
    .db "defer@"
    .dw VE_HEAD
    .set VE_HEAD = VE_DEFERFETCH
XT_DEFERFETCH:
    .dw DO_COLON
PFA_DEFERFETCH:
.endif
    .dw XT_TO_BODY 
    .dw XT_DUP
    .dw XT_ICELLPLUS
    .dw XT_FETCHI
    .dw XT_EXECUTE
    .dw XT_EXIT
