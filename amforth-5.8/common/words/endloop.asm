
.if cpu_msp430==1
    HEADER(XT_ENDLOOP,7,"endloop",DOCOLON)
.endif

.if cpu_avr8==1
VE_ENDLOOP:
    .dw $ff07
    .db "endloop",0
    .dw VE_HEAD
    .set VE_HEAD = VE_ENDLOOP
XT_ENDLOOP:
    .dw DO_COLON
PFA_ENDLOOP:
.endif
;Z ENDLOOP   adrs xt --   L: 0 a1 a2 .. aN --
;   <resolve                backward loop
;   BEGIN L> ?DUP WHILE POSTPONE THEN REPEAT ;
;                                 resolve LEAVEs
; This is a common factor of LOOP and +LOOP.

        .DW XT_LRESOLVE
LOOP1:  .DW XT_L_FROM,XT_QDUP,XT_DOCONDBRANCH
         DEST(LOOP2)
        .DW XT_THEN
	.dw XT_DOBRANCH
         DEST(LOOP1)
LOOP2:  .DW XT_EXIT
