; ( n1 n2 -- n1|n2 ) 
; Compare
; compare two values leave the smaller one

.if cpu_msp430==1
    HEADER(XT_MIN,3,"min",DOCOLON)
.endif

.if cpu_avr8==1


VE_MIN:
    .dw $ff03
    .db "min",0
    .dw VE_HEAD
    .set VE_HEAD = VE_MIN
XT_MIN:
    .dw DO_COLON
PFA_MIN:
.endif
    .dw XT_2DUP
    .dw XT_GREATER
    .dw XT_DOCONDBRANCH
    DEST(PFA_MIN1)
    .dw XT_SWAP
PFA_MIN1:
    .dw XT_DROP
    .dw XT_EXIT
