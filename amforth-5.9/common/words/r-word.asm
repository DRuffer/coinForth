; ( addr len -- xt flags r:word | r:fail )
; Interpreter
; search for a word
.if cpu_msp430==1
    HEADER(XT_REC_WORD,8,"rec:word",DOCOLON)
.endif
.if cpu_avr8==1
VE_REC_WORD:
    .dw $ff08
    .db "rec:word"
    .dw VE_HEAD
    .set VE_HEAD = VE_REC_WORD
XT_REC_WORD:
    .dw DO_COLON
PFA_REC_WORD:
.endif
    .DW XT_FINDNAME
    .dw XT_DUP
    .dw XT_ZEROEQUAL
    .dw XT_DOCONDBRANCH
    DEST(PFA_REC_WORD_FOUND)
        .dw XT_DROP
	.dw XT_R_FAIL
	.dw XT_EXIT
PFA_REC_WORD_FOUND:
    .dw XT_R_WORD

    .dw XT_EXIT

; ( -- addr )
; Interpreter
; actions to handle execution tokens and their flags
.if cpu_msp430==1
    HEADER(XT_R_WORD,6,"r:word",DOROM)
.endif

.if cpu_avr8==1
VE_R_WORD:
    .dw $ff06
    .db "r:word"
    .dw VE_HEAD
    .set VE_HEAD = VE_R_WORD
XT_R_WORD:
    .dw PFA_DOCONSTANT
PFA_R_WORD:
.endif
    .dw XT_R_WORD_INTERPRET
    .dw XT_R_WORD_COMPILE
    .dw XT_R_WORD_POSTPONE

; ( XT flags -- )
; Interpreter
; interpret method for WORD recognizer
.if cpu_msp430==1
    HEADLESS(XT_R_WORD_INTERPRET,DOCOLON)
.endif

.if cpu_avr8==1
XT_R_WORD_INTERPRET:
    .dw DO_COLON
PFA_R_WORD_INTERPRET:
.endif
    .dw XT_DROP ; the flags are in the way
    .dw XT_EXECUTE
    .dw XT_EXIT

; ( XT flags -- )
; Interpreter
; Compile method for WORD recognizer
.if cpu_msp430==1
    HEADLESS(XT_R_WORD_COMPILE,DOCOLON)
.endif
.if cpu_avr8==1
XT_R_WORD_COMPILE:
    .dw DO_COLON
PFA_R_WORD_COMPILE:
.endif
    .dw XT_ZEROLESS
    .dw XT_DOCONDBRANCH
    DEST(PFA_R_WORD_COMPILE1)
	.dw XT_COMMA
        .dw XT_EXIT
PFA_R_WORD_COMPILE1:
        .dw XT_EXECUTE
    .dw XT_EXIT

; ( XT flags -- )
; Interpreter
; Postpone method for WORD recognizer
.if cpu_msp430==1
    HEADLESS(XT_R_WORD_POSTPONE,DOCOLON)
.endif
.if cpu_avr8==1
XT_R_WORD_POSTPONE:
    .dw DO_COLON
PFA_R_WORD_POSTPONE:
.endif
    .dw XT_ZEROLESS
    .dw XT_DOCONDBRANCH
    DEST(PFA_R_WORD_POSTPONE1)
      .dw XT_COMPILE
      .dw XT_COMPILE
PFA_R_WORD_POSTPONE1:
    .dw XT_COMMA
    .dw XT_EXIT
