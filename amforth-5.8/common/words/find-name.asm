; ( c-addr len --  0 | xt -1 | xt 1 ) 
; Tools
; search wordlists for an entry with the name from c-addr/len

.if cpu_msp430==1
    HEADER(XT_FINDNAME,9,"find-name",DOCOLON)
.endif

.if cpu_avr8==1
VE_FINDNAME:
    .dw $ff09
    .db "find-name",0
    .dw VE_HEAD
    .set VE_HEAD = VE_FINDNAME
XT_FINDNAME:
    .dw DO_COLON
PFA_FINDNAME:
.endif
    .dw XT_DOLITERAL
    .dw XT_FINDNAMEA
    .dw XT_DOLITERAL
    .dw CFG_ORDERLISTLEN
    .dw XT_MAPSTACK
    .dw XT_ZEROEQUAL
    .dw XT_DOCONDBRANCH
    DEST(PFA_FINDNAME1)
      .dw XT_2DROP
      .dw XT_ZERO
PFA_FINDNAME1:
    .dw XT_EXIT

.if cpu_msp430==1
    HEADLESS(XT_FINDNAMEA,DOCOLON)
.endif

.if cpu_avr8==1

XT_FINDNAMEA:
    .dw DO_COLON
PFA_FINDNAMEA:
.endif
    .dw XT_TO_R
    .dw XT_2DUP
    .dw XT_R_FROM
    .dw XT_SEARCH_WORDLIST
    .dw XT_DUP
    .dw XT_DOCONDBRANCH
    DEST(PFA_FINDNAMEA1)
      .dw XT_TO_R
      .dw XT_NIP
      .dw XT_NIP
      .dw XT_R_FROM
      .dw XT_TRUE
PFA_FINDNAMEA1:
    .dw XT_EXIT
