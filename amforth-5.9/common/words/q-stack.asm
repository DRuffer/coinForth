; ( --  ) 
; Tools
; check data stack depth and exit to quit if underrun
.if cpu_msp430==1
    HEADER(XT_QSTACK,6,"?stack",DOCOLON)
.endif

.if cpu_avr8==1
VE_QSTACK:
    .dw $ff06
    .db "?stack"
    .dw VE_HEAD
    .set VE_HEAD = VE_QSTACK
XT_QSTACK:
    .dw DO_COLON
PFA_QSTACK:
.endif
    .dw XT_DEPTH
    .dw XT_ZEROLESS
    .dw XT_DOCONDBRANCH
    DEST(PFA_QSTACK1)
      .dw XT_DOLITERAL
      .dw -4
      .dw XT_THROW
PFA_QSTACK1:
    .dw XT_EXIT
