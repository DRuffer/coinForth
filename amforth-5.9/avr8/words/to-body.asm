; ( XT -- PFA )
; Core
; get body from XT
VE_TO_BODY:
    .dw $ff05
    .db ">body",0
    .dw VE_HEAD
    .set VE_HEAD = VE_TO_BODY
XT_TO_BODY:
    .dw PFA_1PLUS
