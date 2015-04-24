; ( -- addr) 
; Stack
; start address of leave stack
VE_LP0:
    .dw $ff03
    .db "lp0",0
    .dw VE_HEAD
    .set VE_HEAD = VE_LP0
XT_LP0:
    .dw PFA_DOVALUE1
PFA_LP0:
    .dw EE_LP0
    .dw XT_EDEFERFETCH
    .dw XT_EDEFERSTORE
