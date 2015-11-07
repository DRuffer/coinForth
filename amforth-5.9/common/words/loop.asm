; (R: loop-sys -- ) (C: do-sys -- ) 
; Compiler
; compile (loop) and resolve the backward branch

.if cpu_msp430==1
    IMMED(XT_LOOP,4,"loop",DOCOLON)
.endif

.if cpu_avr8==1
VE_LOOP:
    .dw $0004
    .db "loop"
    .dw VE_HEAD
    .set VE_HEAD = VE_LOOP
XT_LOOP:
    .dw DO_COLON
PFA_LOOP:
.endif
    .dw XT_COMPILE
    .dw XT_DOLOOP
    .dw XT_ENDLOOP
    .dw XT_EXIT
