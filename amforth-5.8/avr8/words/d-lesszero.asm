; ( d -- flag )
; Compare
; compares if a double double cell number is less than 0
VE_DXT_ZEROLESS:
    .dw $ff03
    .db "d0<",0
    .dw VE_HEAD
    .set VE_HEAD = VE_DXT_ZEROLESS
XT_DXT_ZEROLESS:
    .dw PFA_DXT_ZEROLESS
PFA_DXT_ZEROLESS:
    adiw Y,2
    sbrc tosh,7
    jmp PFA_TRUE1
    jmp PFA_ZERO1
