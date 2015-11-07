; : (value) <builds does> dup @i swap i-cell+ @i execute ;
HEADER(XT_DOVALUE,7,"(value)",DOCOLON)
    .dw XT_DOCREATE
    .dw XT_REVEAL
    .dw XT_COMPILE
    .dw DOVALUE
    .dw XT_EXIT

DOVALUE:
    .dw 04030h, dodoes ; that compiles DOES>
    .dw XT_DUP
    .dw XT_ICELLPLUS
    .dw XT_FETCHI
    .dw XT_EXECUTE
    .dw XT_EXIT
