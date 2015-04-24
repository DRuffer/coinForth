; ( -- ) (R: loop-sys -- )
; Compiler
; immediatly leave the current DO..LOOP

.if cpu_msp430==1
    IMMED(XT_LEAVE,5,"leave",DOCOLON)
.endif

.if cpu_avr8==1
VE_LEAVE:
   .dw $0005
   .db "leave",0
   .dw VE_HEAD
   .set VE_HEAD = VE_LEAVE
XT_LEAVE:
    .dw DO_COLON
PFA_LEAVE:
.endif
    .DW XT_COMPILE,XT_UNLOOP
    .DW XT_AHEAD,XT_TO_L,XT_EXIT
