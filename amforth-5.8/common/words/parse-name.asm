; ( "<name>" -- c-addr u ) 
; String
; In the SOURCE buffer parse whitespace delimited string. Returns string address within SOURCE.

.if cpu_msp430==1
    HEADER(XT_PARSENAME,10,"parse-name",DOCOLON)
.endif

.if cpu_avr8==1

VE_PARSENAME:
    .dw $FF0A 
    .db "parse-name"
    .dw VE_HEAD
    .set VE_HEAD = VE_PARSENAME
XT_PARSENAME:
    .dw DO_COLON 
PFA_PARSENAME:
.endif
    .dw XT_BL
    .dw XT_SKIPSCANCHAR
    .dw XT_EXIT 

; ( c -- addr2 len2 ) 
; String
; skips char and scan what's left in source for char
.if cpu_msp430==1
    HEADLESS(XT_SKIPSCANCHAR,DOCOLON)
.endif

.if cpu_avr8==1
;VE_SKIPSCANCHAR:
;    .dw $FF0A 
;    .db "skipscanchar"
;    .dw VE_HEAD
;    .set VE_HEAD = VE_SKIPSCANCHAR
XT_SKIPSCANCHAR:
    .dw DO_COLON
PFA_SKIPSCANCHAR:
.endif
    .dw XT_TO_R
    .dw XT_SOURCE 
    .dw XT_TO_IN 
    .dw XT_FETCH 
    .dw XT_SLASHSTRING 

    .dw XT_R_FETCH
    .dw XT_CSKIP
    .dw XT_R_FROM
    .dw XT_CSCAN

    ; adjust >IN
    .dw XT_2DUP
    .dw XT_PLUS
    .dw XT_SOURCE 
    .dw XT_DROP
    .dw XT_MINUS
    .dw XT_TO_IN
    .dw XT_STORE
    .dw XT_EXIT
