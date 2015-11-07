; ( n -- flag )
; Compare
; compare with 0 (zero)
VE_ZEROEQUAL:
    .dw $ff02
    .db "0="
    .dw VE_HEAD
    .set VE_HEAD = VE_ZEROEQUAL
XT_ZEROEQUAL:
    .dw PFA_ZEROEQUAL
PFA_ZEROEQUAL:
    or tosh, tosl
    brne PFA_ZERO1
    rjmp PFA_TRUE1
