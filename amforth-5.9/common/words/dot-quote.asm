; ( -- ) (C: "ccc<quote>" -- )
; Compiler
; compiles string into dictionary to be printed at runtime

.if cpu_msp430==1
    ; IMMED(DOTQUOTE,2,"."",DOCOLON)
        DW      link
        DB      0FEh       ; immediate
.set link = $
        DB      2,'.','"'
        .align 16
DOTQUOTE: DW      DOCOLON

.endif

.if cpu_avr8==1


VE_DOTSTRING:
    .dw $0002
    .db ".",$22
    .dw VE_HEAD
    .set VE_HEAD = VE_DOTSTRING
XT_DOTSTRING:
    .dw DO_COLON
PFA_DOTSTRING:
.endif
    .dw XT_SQUOTE
    .dw XT_COMPILE
    .dw XT_ITYPE
    .dw XT_EXIT
