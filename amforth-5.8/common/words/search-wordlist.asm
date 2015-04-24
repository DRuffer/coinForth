; ( c-addr len wid -- [ 0 ] | [ xt [-1|1]] ) 
; Search Order
; searches the word list wid for the word at c-addr/len

.if cpu_msp430==1
    HEADER(XT_SEARCH_WORDLIST,15,"search-wordlist",DOCOLON)
.endif

.if cpu_avr8==1
VE_SEARCH_WORDLIST:
    .dw $ff0f
    .db "search-wordlist",0
    .dw VE_HEAD
    .set VE_HEAD = VE_SEARCH_WORDLIST
XT_SEARCH_WORDLIST:
    .dw DO_COLON
PFA_SEARCH_WORDLIST:
.endif
    .dw XT_TO_R
    .dw XT_ZERO
    .dw XT_DOLITERAL
    .dw XT_ISWORD
    .dw XT_R_FROM
    .dw XT_TRAVERSEWORDLIST
    .dw XT_DUP
    .dw XT_ZEROEQUAL
    .dw XT_DOCONDBRANCH
    DEST(PFA_SEARCH_WORDLIST1)
       .dw XT_2DROP
       .dw XT_DROP
       .dw XT_ZERO
       .dw XT_EXIT
PFA_SEARCH_WORDLIST1:
      ; ... get the XT ...
      .dw XT_DUP
      .dw XT_NFA2CFA
      ; .. and get the header flag
      .dw XT_SWAP
      .dw XT_NAME2FLAGS
      .dw XT_IMMEDIATEQ
    .dw XT_EXIT

.if cpu_msp430==1
    HEADLESS(XT_ISWORD,DOCOLON)
.endif

.if cpu_avr8==1
XT_ISWORD:
    .dw DO_COLON
PFA_ISWORD:
.endif
    ; ( c-addr len 0 nt -- c-addr len 0 true| nt false )
    .dw XT_TO_R
    .dw XT_DROP
    .dw XT_2DUP
    .dw XT_R_FETCH  ; -- addr len addr len nt
    .dw XT_NAME2STRING
    .dw XT_ICOMPARE      ; (-- addr len f )
    .dw XT_DOCONDBRANCH
    DEST(PFA_ISWORD3)
      ; not now
      .dw XT_R_FROM
      .dw XT_DROP
      .dw XT_ZERO
      .dw XT_TRUE         ; maybe next word
      .dw XT_EXIT
PFA_ISWORD3:
      ; we found the word, now clean up iteration data ...
      .dw XT_2DROP
      .dw XT_R_FROM
      .dw XT_ZERO       ; finish traverse-wordlist
      .dw XT_EXIT
