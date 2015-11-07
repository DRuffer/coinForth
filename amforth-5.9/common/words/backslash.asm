; ( "ccc<eol>" -- ) 
; Compiler
; everything up to the end of the current line is a comment

.if cpu_msp430==1
;    HEADER(XT_BACKSLASH,1,'\',DOCOLON)
        DW      link
        DB      0FEh       ; immediate
.set link = $
        DB      1,5ch
        .align 16
XT_BACKSLASH: 
	.DW      DOCOLON
.endif

.if cpu_avr8==1
VE_BACKSLASH:
    .dw $0001
    .db $5c,0
    .dw VE_HEAD
    .set VE_HEAD = VE_BACKSLASH
XT_BACKSLASH:
    .dw DO_COLON
PFA_BACKSLASH:
.endif
    .dw XT_SOURCE
    .dw XT_NIP
    .dw XT_TO_IN
    .dw XT_STORE
    .dw XT_EXIT
