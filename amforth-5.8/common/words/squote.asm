; ( -- addr len) (C: <cchar> -- ) 
; Compiler
; compiles a string to flash, at runtime leaves ( -- flash-addr count) on stack

.if cpu_msp430==1
        DW      link
        DB      0FEh       ; immediate
.set link = $
        DB      2,"s",'"'
        .align 16
XT_SQUOTE: DW      DOCOLON
.endif

.if cpu_avr8==1
VE_SQUOTE:
  .dw $0002
  .db "s",$22
  .dw VE_HEAD
  .set VE_HEAD = VE_SQUOTE
XT_SQUOTE:
    .dw DO_COLON
PFA_SQUOTE:
.endif
    .dw XT_DOLITERAL
    .dw 34   ; 0x22 
    .dw XT_PARSE       ; ( -- addr n)
    .dw XT_STATE
    .dw XT_FETCH
    .dw XT_DOCONDBRANCH
    DEST(PFA_SQUOTE1)
      .dw XT_SLITERAL
PFA_SQUOTE1:
    .dw XT_EXIT
