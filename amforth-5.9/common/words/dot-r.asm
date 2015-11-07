; ( n w -- ) 
; Numeric IO
; singed PNO with single cell numbers, right aligned in width w

.if cpu_msp430==1
;    HEADER(XT_DOTR,2,"..",DOCOLON)
        DW      link
        DB      0FFh
.set link = $
        DB      2,".",'r'
        .align 16
XT_DOTR:
	.DW      DOCOLON
.endif

.if cpu_avr8==1
VE_DOTR:
    .dw $ff02
    .db ".r"
    .dw VE_HEAD
    .set VE_HEAD = VE_DOTR
XT_DOTR:
    .dw DO_COLON
PFA_DOTR:

.endif
    .dw XT_TO_R
    .dw XT_S2D
    .dw XT_R_FROM
    .dw XT_DDOTR
    .dw XT_EXIT
; : .r        ( s n -- )  >r s>d r> d.r ;
