; ( d1 -- addr count ) 
; Numeric IO
; Pictured Numeric Output: convert PNO buffer into an string

.if cpu_msp430==1
    HEADER(XT_SHARP_G,2,"#>",DOCOLON)
.endif

.if cpu_avr8==1
VE_SHARP_G:
    .dw $ff02
    .db "#>"
    .dw VE_HEAD
    .set VE_HEAD = VE_SHARP_G
XT_SHARP_G:
    .dw DO_COLON
PFA_SHARP_G:
.endif
    .dw XT_2DROP
    .dw XT_HLD
    .dw XT_FETCH
    .dw XT_PAD
    .dw XT_OVER
    .dw XT_MINUS
    .dw XT_EXIT
