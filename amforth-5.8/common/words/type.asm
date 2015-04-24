; ( addr n -- ) 
; Character IO
; print a RAM based string

.if cpu_msp430==1
    HEADER(XT_TYPE,4,"type",DOCOLON)
.endif

.if cpu_avr8==1
VE_TYPE:
    .dw $ff04
    .db "type"
    .dw VE_HEAD
    .set VE_HEAD = VE_TYPE
XT_TYPE:
    .dw DO_COLON
PFA_TYPE:

.endif
    .dw XT_BOUNDS
    .dw XT_QDOCHECK
    .dw XT_DOCONDBRANCH
    DEST(PFA_TYPE2)
    .dw XT_DODO
PFA_TYPE1:
    .dw XT_I
    .dw XT_CFETCH
    .dw XT_EMIT
    .dw XT_DOLOOP
    DEST(PFA_TYPE1)
PFA_TYPE2:
    .dw XT_EXIT
