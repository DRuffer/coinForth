; ( nt -- xt ) 
; Tools
; get the XT from a name token
VE_NFA2CFA:
    .dw $ff07
    .db "nfa>cfa"
    .dw VE_HEAD
    .set VE_HEAD = VE_NFA2CFA
XT_NFA2CFA:
    .dw DO_COLON
PFA_NFA2CFA:
    .dw XT_NFA2LFA ; skip to link field
    .dw XT_1PLUS   ; next is the execution token
    .dw XT_EXIT
