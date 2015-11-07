; ( i*x -- j*x )
; System
; runtime of defer
VE_DODEFER:
    .dw $ff07
    .db "(defer)", 0
    .dw VE_HEAD
    .set VE_HEAD = VE_DODEFER
XT_DODEFER:
    .dw DO_COLON
PFA_DODEFER:
    .dw XT_DOCREATE
    .dw XT_REVEAL
    .dw XT_COMPILE
    .dw PFA_DODEFER1
    .dw XT_EXIT
PFA_DODEFER1:
    call_ DO_DODOES
    .dw XT_DUP
    .dw XT_ICELLPLUS
    .dw XT_FETCHI
    .dw XT_EXECUTE 
    .dw XT_EXECUTE
    .dw XT_EXIT

; : (defer) <builds does> dup i-cell+ @i execute execute ;

