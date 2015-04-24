; ( -- ) 
; System
; main loop of amforth. accept - interpret in an endless loop

.if cpu_msp430==1
    HEADER(XT_QUIT,4,"quit",DOCOLON)
.endif

.if cpu_avr8==1
VE_QUIT:
    .dw $ff04
    .db "quit"
    .dw VE_HEAD
    .set VE_HEAD = VE_QUIT
XT_QUIT:
    .dw DO_COLON
PFA_QUIT:
.endif
PFA_QUIT1:
    .dw XT_LP0,XT_LP,XT_STORE
    .dw XT_SP0
    .dw XT_SP_STORE
    .dw XT_RP0
    .dw XT_RP_STORE
    .dw XT_LBRACKET

PFA_QUIT2:
    .dw XT_STATE
    .dw XT_FETCH
    .dw XT_ZEROEQUAL
    .dw XT_DOCONDBRANCH
    DEST(PFA_QUIT4)
    .dw XT_PROMPTREADY
PFA_QUIT4:
    .dw XT_REFILL
    .dw XT_DOCONDBRANCH
    DEST(PFA_QUIT2)
    .dw XT_DOLITERAL
    .dw XT_INTERPRET
    .dw XT_CATCH
    .dw XT_QDUP
    .dw XT_DOCONDBRANCH
    DEST(PFA_QUIT3)
	.dw XT_DUP
	.dw XT_DOLITERAL
	.dw -2
	.dw XT_LESS
	.dw XT_DOCONDBRANCH
	DEST(PFA_QUIT5)
	.dw XT_PROMPTERROR
PFA_QUIT5:
	.dw XT_DOBRANCH
	DEST(PFA_QUIT1)
PFA_QUIT3:
    .dw XT_PROMPTOK
    .dw XT_DOBRANCH
    DEST(PFA_QUIT2)
    .dw XT_EXIT ; never reached

