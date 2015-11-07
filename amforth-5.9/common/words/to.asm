; ( n <name> -- ) 
; Tools
; store the TOS to the named value (eeprom cell)

.if cpu_msp430==1
    IMMED(XT_TO,2,"to",DOCOLON)
.endif

.if cpu_avr8==1
VE_TO:
    .dw $0002
    .db "to"
    .dw VE_HEAD
    .set VE_HEAD = VE_TO
XT_TO:
    .dw DO_COLON
PFA_TO:
.endif
    .dw XT_TICK
    .dw XT_TO_BODY
    .dw XT_STATE
    .dw XT_FETCH
    .dw XT_DOCONDBRANCH
    DEST(PFA_TO1)
    .dw XT_COMPILE
    .dw XT_DOTO
    .dw XT_COMMA
    .dw XT_EXIT

; ( n -- ) (R: IP -- IP+1)
; Tools
; runtime portion of to
;VE_DOTO:
;    .dw $ff04
;    .db "(to)"
;    .dw VE_HEAD
;    .set VE_HEAD = VE_DOTO
.if cpu_msp430==1
    HEADLESS(XT_DOTO,DOCOLON)
.endif

.if cpu_avr8==1

XT_DOTO:
    .dw DO_COLON
PFA_DOTO:
.endif
    .dw XT_R_FROM
    .dw XT_DUP
    .dw XT_ICELLPLUS
    .dw XT_TO_R
    .dw XT_FETCHI
PFA_TO1:
    .dw XT_DUP
    .dw XT_ICELLPLUS
    .dw XT_ICELLPLUS
    .dw XT_FETCHI
    .dw XT_EXECUTE
    .dw XT_EXIT
