; ( addr -- addr' )
; Compiler
; skip to the next cell in flash
VE_ICELLPLUS:
    .dw $FF07
    .db "i-cell+",0
    .dw VE_HEAD
    .set VE_HEAD = VE_ICELLPLUS
XT_ICELLPLUS:
    .dw DO_COLON
PFA_ICELLPLUS:
    .dw XT_1PLUS
    .dw XT_EXIT
