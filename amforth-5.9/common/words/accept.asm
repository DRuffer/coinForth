
.if cpu_msp430==1
    HEADER(XT_ACCEPT,6,"accept",DOCOLON)
.endif

.if cpu_avr8==1
VE_ACCEPT:
    .dw $ff06
    .db "accept"
    .dw VE_HEAD
    .set VE_HEAD = VE_ACCEPT
XT_ACCEPT:
    .dw DO_COLON
PFA_ACCEPT:

.endif
        .DW XT_OVER,XT_PLUS,XT_1MINUS,XT_OVER
ACC1:   .DW XT_KEY,XT_DUP,XT_CRLFQ,XT_ZEROEQUAL,XT_DOCONDBRANCH
        DEST(ACC5)
        .DW XT_DUP,XT_DOLITERAL,8,XT_EQUAL,XT_DOCONDBRANCH
        DEST(ACC3)
        .DW XT_DROP,XT_ROT,XT_2DUP,XT_GREATER,XT_TO_R,XT_ROT,XT_ROT,XT_R_FROM,XT_DOCONDBRANCH
	DEST(ACC6)
	.DW XT_BS,XT_1MINUS,XT_TO_R,XT_OVER,XT_R_FROM,XT_UMAX
ACC6:
        .DW XT_DOBRANCH
        DEST(ACC4)
ACC3:   .DW XT_DUP,XT_EMIT,XT_OVER,XT_CSTORE,XT_1PLUS,XT_OVER,XT_UMIN
ACC4:   .DW XT_DOBRANCH
        DEST(ACC1)
ACC5:   .DW XT_DROP,XT_NIP,XT_SWAP,XT_MINUS,XT_CR,XT_EXIT


; ( --  ) 
; System
; send a backspace character to overwrite the current char
.if cpu_msp430==1
    HEADLESS(XT_BS,DOCOLON)
.endif

.if cpu_avr8==1

;VE_BS:
;    .dw $ff02
;    .db "bs"
;    .dw VE_HEAD
;    .set VE_HEAD = VE_BS
XT_BS:
    .dw DO_COLON
.endif
    .dw XT_DOLITERAL
    .dw 8
    .dw XT_DUP
    .dw XT_EMIT
    .dw XT_SPACE
    .dw XT_EMIT
    .dw XT_EXIT


; ( c -- f ) 
; System
; is the character a line end character?
.if cpu_msp430==1
    HEADLESS(XT_CRLFQ,DOCOLON)
.endif

.if cpu_avr8==1
;VE_CRLFQ:
;    .dw $ff02
;    .db "crlf?"
;    .dw VE_HEAD
;    .set VE_HEAD = VE_CRLFQ
XT_CRLFQ:
    .dw DO_COLON
.endif
    .dw XT_DUP
    .dw XT_DOLITERAL
    .dw 13
    .dw XT_EQUAL
    .dw XT_SWAP
    .dw XT_DOLITERAL
    .dw 10
    .dw XT_EQUAL
    .dw XT_OR
    .dw XT_EXIT
