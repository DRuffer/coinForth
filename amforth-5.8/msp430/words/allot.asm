;C ALLOT   n --         allocate n bytes in dict
;   DP +! ;
    HEADER(XT_ALLOT,5,"allot",DOCOLON)
        DW XT_DP,XT_PLUSSTORE,XT_EXIT
