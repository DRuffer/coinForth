; ( addr1 n1 c -- addr2 n2 ) 
; String
; skips leading occurancies in string at addr1/n1 leaving addr2/n2 pointing to the 1st non-c character

.if cpu_msp430==1
    HEADER(XT_CSKIP,5,"cskip",DOCOLON)
.endif

.if cpu_avr8==1
VE_CSKIP:
    .dw $ff05
    .db "cskip",0
    .dw VE_HEAD
    .set VE_HEAD = VE_CSKIP
XT_CSKIP:
    .dw DO_COLON
PFA_CSKIP:
.endif
    .dw XT_TO_R           ; ( -- addr1 n1 )
PFA_CSKIP1:
    .dw XT_DUP            ; ( -- addr' n' n' )
    .dw XT_DOCONDBRANCH   ; ( -- addr' n')
    DEST(PFA_CSKIP2)
    .dw XT_OVER           ; ( -- addr' n' addr' )
    .dw XT_CFETCH         ; ( -- addr' n' c' )
    .dw XT_R_FETCH        ; ( -- addr' n' c' c )
    .dw XT_EQUAL          ; ( -- addr' n' f )
    .dw XT_DOCONDBRANCH   ; ( -- addr' n')
    DEST(PFA_CSKIP2)
    .dw XT_DOLITERAL
    .dw 1
    .dw XT_SLASHSTRING
    .dw XT_DOBRANCH
    DEST(PFA_CSKIP1)
PFA_CSKIP2:
    .dw XT_R_FROM
    .dw XT_DROP           ; ( -- addr2 n2)
    .dw XT_EXIT
