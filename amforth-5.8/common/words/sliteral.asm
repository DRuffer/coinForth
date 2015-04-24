; (C: addr len -- ) 
; String
; compiles a string to flash, at runtime leaves ( -- flash-addr count) on stack

.if cpu_msp430==1
    IMMED(XT_SLITERAL,8,"sliteral",DOCOLON)
.endif

.if cpu_avr8==1
VE_SLITERAL:
  .dw $0008
  .db "sliteral"
  .dw VE_HEAD
  .set VE_HEAD = VE_SLITERAL
XT_SLITERAL:
    .dw DO_COLON
PFA_SLITERAL:
.endif
    .dw XT_COMPILE
    .dw XT_DOSLITERAL    ; ( -- addr n)
    .dw XT_SCOMMA
    .dw XT_EXIT
