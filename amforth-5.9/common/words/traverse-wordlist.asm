; ( i*x xt wid -- j*x ) 
; Tools Ext (2012)
; call the xt for every member of the wordlist wid until xt returns false

.if cpu_msp430==1
    HEADER(XT_TRAVERSEWORDLIST,17,"traverse-wordlist",DOCOLON)
.endif

.if cpu_avr8==1
VE_TRAVERSEWORDLIST:
    .dw $ff11
    .db "traverse-wordlist",0
    .dw VE_HEAD
    .set VE_HEAD = VE_TRAVERSEWORDLIST
XT_TRAVERSEWORDLIST:
    .dw DO_COLON
PFA_TRAVERSEWORDLIST:

.endif
    .dw XT_FETCHE
PFA_TRAVERSEWORDLIST1:
    .dw XT_DUP           ; ( -- xt nt nt )
    .dw XT_DOCONDBRANCH  ; ( -- nt ) is nfa = counted string
    DEST(PFA_TRAVERSEWORDLIST2)
    .dw XT_2DUP
    .dw XT_2TO_R
    .dw XT_SWAP
    .dw XT_EXECUTE
    .dw XT_2R_FROM
    .dw XT_ROT
    .dw XT_DOCONDBRANCH
    DEST(PFA_TRAVERSEWORDLIST2)
    .dw XT_NFA2LFA
    .dw XT_FETCHI
    .dw XT_DOBRANCH      ; ( -- addr )
    DEST(PFA_TRAVERSEWORDLIST1)       ; ( -- addr )
PFA_TRAVERSEWORDLIST2:
    .dw XT_2DROP
    .dw XT_EXIT

; : traverse-wordlist ( i*x xt wid -- i*x' ) 
;        begin @ dup 
;        while 
;          2dup 2>r 
;          cell + swap execute ( i*x nt -- i*x' f ) 
;          2r> rot 
;        while repeat then 2drop ; 
