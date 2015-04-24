;X DABS     d1 -- +d2    absolute value dbl.prec.
;   DUP ?DNEGATE ;
    HEADER(XT_DABS,4,"dabs",DOCOLON)
        DW XT_DUP,XT_QDNEGATE,XT_EXIT
