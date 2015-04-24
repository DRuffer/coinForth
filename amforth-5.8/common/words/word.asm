; ( c -- addr ) 
; Tools
; skip leading delimiter character and parse SOURCE until the next delimiter. copy the word to HERE

.if cpu_msp430==1
    HEADER(XT_WORD,5,"word",DOCOLON)
.endif

.if cpu_avr8==1
VE_WORD:
    .dw $ff04
    .db "word"
    .dw VE_HEAD
    .set VE_HEAD = VE_WORD
XT_WORD:
    .dw DO_COLON
PFA_WORD:
.endif
    .dw XT_SKIPSCANCHAR ; factor for both parse/word
    ; move to HERE
    .dw XT_HERE
    .dw XT_PLACE
    ; leave result
    .dw XT_HERE
    .dw XT_EXIT
