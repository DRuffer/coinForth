; ( -- ) 
; Tools
; stack dump

.if cpu_msp430==1
;    HEADER(XT_DOTS,2,"..",DOCOLON)
        DW      link
        DB      0FFh
.set link = $
        DB      2,".",'s'
        .align 16
XT_DOTS:
	.DW      DOCOLON
.endif

.if cpu_avr8==1
VE_DOTS:
    .dw $ff02
    .db ".s"
    .dw VE_HEAD
    .set VE_HEAD = VE_DOTS
XT_DOTS:
    .dw DO_COLON
PFA_DOTS:
.endif
    .dw XT_DEPTH
    .dw XT_UDOT
    .dw XT_SPACE
    .dw XT_DEPTH
    .dw XT_ZERO
    .dw XT_QDOCHECK
    .dw XT_DOCONDBRANCH
    DEST(PFA_DOTS2)
    .dw XT_DODO
PFA_DOTS1:
    .dw XT_I
    .dw XT_PICK
    .dw XT_UDOT
    .dw XT_DOLOOP
    DEST(PFA_DOTS1)
PFA_DOTS2:
    .dw XT_EXIT
