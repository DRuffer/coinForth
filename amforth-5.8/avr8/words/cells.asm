; ( n1 -- n2 ) 
; Arithmetics
; n2 is the size in address units of n1 cells
VE_CELLS:
    .dw $ff05
    .db "cells",0
    .dw VE_HEAD
    .set VE_HEAD = VE_CELLS
XT_CELLS:
    .dw PFA_2STAR
