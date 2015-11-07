; ( f -- +/-1 )
; System
; return +1 if immediate, -1 otherwise, flag from name>flags
 HEADLESS(XT_IMMEDIATEQ,DOCOLON)
    .dw XT_DOLITERAL
    .dw 1
    .dw XT_AND
    .dw XT_ZEROEQUAL
    .dw XT_DOCONDBRANCH
    DEST(IMMEDIATEQ1)
     .dw XT_ONE
    .dw XT_EXIT
IMMEDIATEQ1:
    ; not immediate
    .dw XT_TRUE
    .dw XT_EXIT
