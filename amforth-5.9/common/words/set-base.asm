; ( addr len -- addr' len' ) 
; Numeric IO
; skip a numeric prefix character

.if cpu_msp430==1
    HEADLESS(XT_BASES,DOROM)
.endif

.if cpu_avr8==1
XT_BASES:
    .dw PFA_DOCONSTANT
.endif
    .dw 10,16,2,10 ; last one could a 8 instead.

.if cpu_msp430==1
    HEADLESS(XT_SET_BASE,DOCOLON)
.endif

.if cpu_avr8==1
XT_SET_BASE:
    .dw DO_COLON 
PFA_SET_BASE:        ; ( adr1 len1 -- adr2 len2 ) 
.endif
    .dw XT_OVER
    .dw XT_CFETCH
    .dw XT_DOLITERAL
    .dw 35
    .dw XT_MINUS
    .dw XT_DUP
    .dw XT_ZERO
    .dw XT_DOLITERAL
    .dw 4
    .dw XT_WITHIN
    .dw XT_DOCONDBRANCH
    DEST(SET_BASE1)
	.if cpu_msp430==1
	    .dw XT_CELLS
	.endif
	.dw XT_BASES
	.dw XT_PLUS
	.dw XT_FETCHI
	.dw XT_BASE
	.dw XT_STORE
	.dw XT_DOLITERAL
	.dw 1
	.dw XT_SLASHSTRING
	.dw XT_DOBRANCH
	DEST(SET_BASE2)
SET_BASE1:
	.dw XT_DROP
SET_BASE2:
    .dw XT_EXIT 

; create bases 10 , 16 , 2 , 8 ,
; : set-base 35 - dup 0 4 within if 
;    bases + @i base ! 1 /string 
;   else 
;    drop
;   then ;
