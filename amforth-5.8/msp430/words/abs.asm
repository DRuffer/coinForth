;C ABS     n1 -- +n2     absolute value
;   DUP ?NEGATE ;
    HEADER(XT_ABS,3,"abs",DOCOLON)
        DW XT_DUP,XT_QNEGATE,XT_EXIT
