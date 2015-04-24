; ( nt -- addr len ) 
; Tools Ext (2012)
; get a (flash) string from a name token nt

.if cpu_msp430==1
    HEADER(XT_NAME2STRING,11,"name>string",DOCOLON)
.endif

.if cpu_avr8==1
VE_NAME2STRING:
    .dw $ff0b
    .db "name>string",0
    .dw VE_HEAD
    .set VE_HEAD = VE_NAME2STRING
XT_NAME2STRING:
    .dw DO_COLON
PFA_NAME2STRING:

.endif
    .dw XT_ICOUNT   ; ( -- addr n )
    .dw XT_DOLITERAL
    .dw 255
    .dw XT_AND      ; mask immediate bit
    .dw XT_EXIT
