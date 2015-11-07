; ( -- ) 
; Character IO
; emits a space (bl)

.if cpu_msp430==1
    HEADER(XT_SPACE,5,"space",DOCOLON)
.endif

.if cpu_avr8==1
VE_SPACE:
    .dw $ff05
    .db "space",0
    .dw VE_HEAD
    .set VE_HEAD = VE_SPACE
XT_SPACE:
    .dw DO_COLON
PFA_SPACE:
.endif
    .dw XT_BL
    .dw XT_EMIT
    .dw XT_EXIT
