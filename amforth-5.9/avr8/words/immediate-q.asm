; ( addr -- addr+1 n )  
; Tools
; get count information out of a counted string in flash
;VE_IMMEDIATEQ:
;    .dw $ff06
;    .db "immediate?"
;    .dw VE_HEAD
;    .set VE_HEAD = VE_IMMEDIATEQ
XT_IMMEDIATEQ:
    .dw DO_COLON
PFA_IMMEDIATEQ:
    .dw XT_DOLITERAL
    .dw $8000
    .dw XT_AND
    .dw XT_ZEROEQUAL
    .dw XT_DOCONDBRANCH
    DEST(IMMEDIATEQ1)
     .dw XT_DOLITERAL
     .dw 1
     .dw XT_EXIT
IMMEDIATEQ1:
    ; not immediate
    .dw XT_TRUE
    .dw XT_EXIT
