; ( nt -- f ) 
; Tools
; get the flags from a name token
VE_NAME2FLAGS:
    .dw $ff0a
    .db "name>flags"
    .dw VE_HEAD
    .set VE_HEAD = VE_NAME2FLAGS
XT_NAME2FLAGS:
    .dw DO_COLON
PFA_NAME2FLAGS:
    .dw XT_FETCHI ; skip to link field
    .dw XT_DOLITERAL
    .dw $ff00
    .dw XT_AND
    .dw XT_EXIT
