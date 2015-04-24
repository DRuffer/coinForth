; ( d1 n1 -- d2) 
; Arithmetics
; add a number to a double cell
VE_MPLUS:
    .dw $ff02
    .db "m+"
    .dw VE_HEAD
    .set VE_HEAD = VE_MPLUS
XT_MPLUS:
    .dw DO_COLON
PFA_MPLUS:
    .dw XT_S2D
    .dw XT_DPLUS
    .dw XT_EXIT
