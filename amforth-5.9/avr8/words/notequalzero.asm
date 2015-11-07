; ( n -- flag ) 
; Compare
; true if n is not zero
VE_NOTZEROEQUAL:
    .dw $ff03
    .db "0<>",0
    .dw VE_HEAD
    .set VE_HEAD = VE_NOTZEROEQUAL
XT_NOTZEROEQUAL:
    .dw DO_COLON
PFA_NOTZEROEQUAL:
    .dw XT_ZEROEQUAL
    .dw XT_ZEROEQUAL
    .dw XT_EXIT
