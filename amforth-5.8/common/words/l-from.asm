
.if cpu_msp430==1
    HEADER(XT_L_FROM,2,"l>",DOCOLON)
.endif

.if cpu_avr8==1
VE_L_FROM:
    .dw $ff02
    .db "l>"
    .dw VE_HEAD
    .set VE_HEAD = VE_L_FROM
XT_L_FROM:
    .dw DO_COLON
PFA_L_FROM:

.endif
;Z L>   -- x   L: x --      move from leave stack
;   LP @ @  -2 LP +! ;

    .dw XT_LP
    .dw XT_FETCH
    .dw XT_FETCH
    .dw XT_DOLITERAL
    .dw -2
    .dw XT_LP
    .dw XT_PLUSSTORE
    .dw XT_EXIT
