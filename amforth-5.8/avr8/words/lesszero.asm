; ( n1 -- flag)
; Compare
; compare with zero
VE_ZEROLESS:
    .dw $ff02
    .db "0<"
    .dw VE_HEAD
    .set VE_HEAD = VE_ZEROLESS
XT_ZEROLESS:
    .dw PFA_ZEROLESS
PFA_ZEROLESS:
    sbrc tosh,7
    rjmp PFA_TRUE1
    rjmp PFA_ZERO1
