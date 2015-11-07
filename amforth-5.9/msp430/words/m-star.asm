;C M*     n1 n2 -- d    signed 16*16->32 multiply
;   2DUP XOR >R        carries sign of the result
;   XT_SWAP ABS SWAP ABS UM*
;   R> ?DNEGATE ;
    HEADER(XT_MSTAR,2,"m*",DOCOLON)
        DW XT_2DUP,XT_XOR,XT_TO_R
        DW XT_SWAP,XT_ABS,XT_SWAP,XT_ABS,XT_UMSTAR
        DW XT_R_FROM,XT_QDNEGATE,XT_EXIT
