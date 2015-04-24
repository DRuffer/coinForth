; ( -- addr )
; Interpreter
; there is no parser for this recognizer, this is the default and failsafe part

.if cpu_msp430==1
    HEADER(XT_R_FAIL,6,"r:fail",DOROM)
.endif

.if cpu_avr8==1
VE_R_FAIL:
    .dw $ff06
    .db "r:fail"
    .dw VE_HEAD
    .set VE_HEAD = VE_R_FAIL
XT_R_FAIL:
    .dw PFA_DOCONSTANT
PFA_R_FAIL:
.endif
    .dw XT_FAIL  ; interpret
    .dw XT_FAIL  ; compile
    .dw XT_FAIL  ; postpone

; ( addr len -- )
; Interpreter
; default failure action: throw exception -13.
.if cpu_msp430==1
    HEADLESS(XT_FAIL,DOCOLON)
.endif
.if cpu_avr8==1
;VE_FAIL:
;    .dw $ff04
;    .db "fail"
;    .dw VE_HEAD
;    .set VE_HEAD = VE_FAIL
XT_FAIL:
    .dw DO_COLON
PFA_FAIL:
.endif
    .dw XT_DOLITERAL
    .dw -13
    .dw XT_THROW
