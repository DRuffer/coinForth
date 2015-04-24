; ( C --  c) 
; String
; if C is an uppercase letter convert it to lowercase

.if cpu_msp430==1
    HEADER(XT_TOLOWER,7,"tolower",DOCOLON)
.endif

.if cpu_avr8==1


VE_TOLOWER:
    .dw $ff07
    .db "tolower",0
    .dw VE_HEAD
    .set VE_HEAD = VE_TOLOWER
XT_TOLOWER:
    .dw DO_COLON
PFA_TOLOWER:
.endif
    .dw XT_DUP
    .dw XT_DOLITERAL
    .dw 'A'
    .dw XT_DOLITERAL
    .dw 'Z'+1
    .dw XT_WITHIN
    .dw XT_DOCONDBRANCH
    DEST(PFA_TOLOWER0)
    .dw XT_DOLITERAL
    .dw 32
    .dw XT_OR 
PFA_TOLOWER0:
    .dw XT_EXIT 
