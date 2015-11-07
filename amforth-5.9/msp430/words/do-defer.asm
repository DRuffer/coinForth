; : (defer) <builds does> dup @i swap i-cell+ @i execute execute ;
HEADER(XT_DODEFER,7,"(defer)",DOCOLON)
    .dw XT_DOCREATE
    .dw XT_REVEAL
    .dw XT_COMPILE
    .dw DODEFER
    .dw XT_EXIT

DODEFER:
    .dw 04030h, dodoes ; that compiles DOES>
    .dw XT_DUP
    .dw XT_ICELLPLUS
    .dw XT_FETCHI
    .dw XT_EXECUTE
    .dw XT_EXECUTE
    .dw XT_EXIT
