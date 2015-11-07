; ( -- addr ) 
; System Variable
; leave stack pointer
VE_LP:
    .dw $ff02
    .db "lp"
    .dw VE_HEAD
    .set VE_HEAD = VE_LP
XT_LP:
    .dw PFA_DOVARIABLE
PFA_LP:
    .dw ram_lp

.dseg
ram_lp: .byte 2
.cseg

