; (addr len -- [n|d size] f) 
; Numeric IO
; convert a string at addr to a number

.if cpu_msp430==1
    HEADER(XT_NUMBER,6,"number",DOCOLON)
.endif

.if cpu_avr8==1
VE_NUMBER:
    .dw $ff06
    .db "number"
    .dw VE_HEAD
    .set VE_HEAD = VE_NUMBER
XT_NUMBER:
    .dw DO_COLON
PFA_NUMBER:
.endif
    .dw XT_BASE
    .dw XT_FETCH
    .dw XT_TO_R
    .dw XT_QSIGN
    .dw XT_TO_R
    .dw XT_SET_BASE
    .dw XT_QSIGN
    .dw XT_R_FROM
    .dw XT_OR
    .dw XT_TO_R
    ; check whether something is left
    .dw XT_DUP
    .dw XT_ZEROEQUAL
    .dw XT_DOCONDBRANCH
    DEST(PFA_NUMBER0)
      ; nothing is left. It cannot be a number at all
      .dw XT_2DROP
      .dw XT_R_FROM
      .dw XT_DROP
      .dw XT_R_FROM
      .dw XT_BASE
      .dw XT_STORE
      .dw XT_ZERO
      .dw XT_EXIT
PFA_NUMBER0:
    .dw XT_2TO_R
    .dw XT_ZERO       ; starting value
    .dw XT_ZERO
    .dw XT_2R_FROM
    .dw XT_TO_NUMBER ; ( 0. addr len -- d addr' len'
    ; check length of the remaining string.
    ; if zero: a single cell number is entered
    .dw XT_QDUP
    .dw XT_DOCONDBRANCH
    DEST(PFA_NUMBER1)
    ; if equal 1: mayba a trailing dot? --> double cell number
    .dw XT_DOLITERAL
    .dw 1
    .dw XT_EQUAL
    .dw XT_DOCONDBRANCH
    DEST(PFA_NUMBER2)
	; excatly one character is left
	.dw XT_CFETCH
	.dw XT_DOLITERAL
	.dw 46 ; .
	.dw XT_EQUAL
	.dw XT_DOCONDBRANCH
	DEST(PFA_NUMBER6)
	; its a double cell number
        ; incorporate sign into number
	.dw XT_R_FROM
        .dw XT_DOCONDBRANCH
	DEST(PFA_NUMBER3)
        .dw XT_DNEGATE
PFA_NUMBER3:
	.dw XT_DOLITERAL
	.dw 2
	.dw XT_DOBRANCH
	DEST(PFA_NUMBER5)
PFA_NUMBER2:
	.dw XT_DROP
PFA_NUMBER6:
	.dw XT_2DROP
	.dw XT_R_FROM
	.dw XT_DROP
        .dw XT_R_FROM
        .dw XT_BASE
        .dw XT_STORE
	.dw XT_ZERO
	.dw XT_EXIT
PFA_NUMBER1:
    .dw XT_2DROP ; remove the address
    ; incorporate sign into number
    .dw XT_R_FROM
    .dw XT_DOCONDBRANCH
    DEST(PFA_NUMBER4)
    .dw XT_NEGATE
PFA_NUMBER4:
    .dw XT_DOLITERAL
    .dw 1
PFA_NUMBER5:
    .dw XT_R_FROM
    .dw XT_BASE
    .dw XT_STORE
    .dw XT_TRUE
    .dw XT_EXIT
