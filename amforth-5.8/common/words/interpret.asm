; (i*x - j*x )
; System
; Interpret SOURCE word by word.

.if cpu_msp430==1
    HEADER(XT_INTERPRET,9,"interpret",DOCOLON)
.endif

.if cpu_avr8==1
VE_INTERPRET:
    .dw $ff09
    .db "interpret",0
    .dw VE_HEAD
    .set VE_HEAD = VE_INTERPRET
XT_INTERPRET:
    .dw DO_COLON
.endif
PFA_INTERPRET:
    .dw XT_PARSENAME ; ( -- addr len )
    .dw XT_QDUP   ; ( -- addr len len | addr 0)
    .dw XT_DOCONDBRANCH
    DEST(PFA_INTERPRET2)
    .dw XT_DORECOGNIZER

    .dw XT_STATE
    .dw XT_FETCH
    .dw XT_DOCONDBRANCH
    DEST(PFA_INTERPRET1)
      .dw XT_1PLUS   ; we need the compile action
    .if cpu_msp430==1
      .dw XT_1PLUS
    .endif
PFA_INTERPRET1:
    .dw XT_FETCHI
    .dw XT_EXECUTE
    .dw XT_QSTACK
    .dw XT_DOBRANCH
    DEST(PFA_INTERPRET)
PFA_INTERPRET2:
    .dw XT_DROP
    .dw XT_EXIT
