; ( char "ccc<char>" -- c-addr u ) 
; String
; in input buffer parse ccc delimited string by the delimiter char.

.if cpu_msp430==1
    HEADER(XT_PARSE,5,"parse",DOCOLON)
.endif

.if cpu_avr8==1
VE_PARSE:
    .dw $ff05
    .db "parse",0
    .dw VE_HEAD
    .set VE_HEAD = VE_PARSE
XT_PARSE:
    .dw DO_COLON
PFA_PARSE:
.endif
    .dw XT_TO_R     ; ( -- )
    .dw XT_SOURCE   ; ( -- addr len)
    .dw XT_TO_IN     ; ( -- addr len >in)
    .dw XT_FETCH
    .dw XT_SLASHSTRING ; ( -- addr' len' )

    .dw XT_R_FROM      ; ( -- addr' len' c)
    .dw XT_CSCAN       ; ( -- addr' len'')
    .dw XT_DUP         ; ( -- addr' len'' len'')
    .dw XT_1PLUS
    .dw XT_TO_IN        ; ( -- addr' len'' len'' >in)
    .dw XT_PLUSSTORE   ; ( -- addr' len')
    .dw XT_DOLITERAL
    .dw 1
    .dw XT_SLASHSTRING
    .dw XT_EXIT
