; ( wid -- ) 
; Tools
; prints the name of the words in a wordlist

.if cpu_msp430==1
    HEADER(XT_SHOWWORDLIST,13,"show-wordlist",DOCOLON)
.endif

.if cpu_avr8==1
VE_SHOWWORDLIST:
    .dw $ff0d
    .db "show-wordlist",0
    .dw VE_HEAD
    .set VE_HEAD = VE_SHOWWORDLIST
XT_SHOWWORDLIST:
    .dw DO_COLON
PFA_SHOWWORDLIST:
.endif
    .dw XT_DOLITERAL
    .dw XT_SHOWWORD
    .dw XT_SWAP
    .dw XT_TRAVERSEWORDLIST
    .dw XT_EXIT

.if cpu_msp430==1
    HEADLESS(XT_SHOWWORD,DOCOLON)
.endif

.if cpu_avr8==1
XT_SHOWWORD:
    .dw DO_COLON
PFA_SHOWWORD:
.endif
    .dw XT_NAME2STRING
    .dw XT_ITYPE
    .dw XT_SPACE         ; ( -- addr n)
    .dw XT_TRUE
    .dw XT_EXIT
