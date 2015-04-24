
.if cpu_msp430==1
    HEADLESS(XT_QSIGN,DOCOLON)
.endif

.if cpu_avr8==1
XT_QSIGN:
    .dw DO_COLON 
PFA_QSIGN:        ; ( c -- ) 
.endif
    .dw XT_OVER    ; ( -- addr len addr )
    .dw XT_CFETCH
    .dw XT_DOLITERAL
    .dw '-'
    .dw XT_EQUAL  ; ( -- addr len flag )
    .dw XT_DUP
    .dw XT_TO_R
    .dw XT_DOCONDBRANCH
    DEST(PFA_NUMBERSIGN_DONE)
    .dw XT_DOLITERAL      ; skip sign character
    .dw 1
    .dw XT_SLASHSTRING
PFA_NUMBERSIGN_DONE:
    .dw XT_R_FROM
    .dw XT_EXIT
