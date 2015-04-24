; ( d -- 0 ) 
; Numeric IO
; pictured numeric output: convert all digits until 0 (zero) is reached

.if cpu_msp430==1
    HEADER(XT_SHARP_S,2,"#s",DOCOLON)
.endif

.if cpu_avr8==1
VE_SHARP_S:
    .dw $ff02
    .db "#s"
    .dw VE_HEAD
    .set VE_HEAD = VE_SHARP_S
XT_SHARP_S:
    .dw DO_COLON
PFA_SHARP_S:
.endif
NUMS1:
    .dw XT_SHARP
    .dw XT_2DUP
    .dw XT_OR
    .dw XT_ZEROEQUAL
    .dw XT_DOCONDBRANCH
    DEST(NUMS1) ; PFA_SHARP_S
    .dw XT_EXIT
