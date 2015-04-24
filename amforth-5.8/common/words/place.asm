; ( addr1 len1 addr2 -- ) 
; String
; copy string as counted string

.if cpu_msp430==1
    HEADER(XT_PLACE,5,"place",DOCOLON)
.endif

.if cpu_avr8==1
VE_PLACE:
    .dw $ff05
    .db "place",0
    .dw VE_HEAD
    .set VE_HEAD = VE_PLACE
XT_PLACE:
    .dw DO_COLON
PFA_PLACE:
.endif
    .dw XT_2DUP        ; ( -- addr1 len1 addr2 len1 addr2)
    .dw XT_CSTORE      ; ( -- addr1 len1 addr2)
    .dw XT_1PLUS       ; ( -- addr1 len1 addr2')
    .dw XT_SWAP        ; ( -- addr1 addr2' len1)
    .dw XT_CMOVE       ; ( --- )
    .dw XT_EXIT
