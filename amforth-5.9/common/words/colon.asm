; ( -- ) (C: "<spaces>name" -- )
; Compiler
; create a named entry in the dictionary, XT is DO_COLON

.if cpu_msp430==1
    HEADER(XT_COLON,1,":",DOCOLON)
.endif

.if cpu_avr8==1
VE_COLON:
    .dw $ff01
    .db ":",0
    .dw VE_HEAD
    .set VE_HEAD = VE_COLON
XT_COLON:
    .dw DO_COLON
PFA_COLON:
.endif
    .dw XT_DOCREATE
    .dw XT_COLONNONAME
    .dw XT_DROP
    .dw XT_EXIT
