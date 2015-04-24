;C ABORT"  i*x 0  -- i*x   R: j*x -- j*x  x1=0
;C         i*x x1 --       R: j*x --      x1<>0
;   POSTPONE IS" POSTPONE ?ABORT ; IMMEDIATE

.if cpu_msp430==1
    ; IMMED(ABORTQUOTE,6,"ABORT"",DOCOLON)
        DW      link
        DB      0FEh       ; immediate
.set link = $
        DB      6,"abort",'"'
        .align 16
XT_ABORTQUOTE: 
	.DW      DOCOLON
.endif

.if cpu_avr8==1
VE_ABORTQUOTE:
    .dw $0006
    .db "abort",'"'
    .dw VE_HEAD
    .set VE_HEAD = VE_ABORTQUOTE
XT_ABORTQUOTE:
    .dw DO_COLON
PFA_ABORTQUOTE:
.endif
    .dw XT_SQUOTE
    .dw XT_COMPILE
    .dw XT_QABORT
    .DW XT_EXIT
