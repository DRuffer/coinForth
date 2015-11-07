;C COUNT   c-addr1 -- c-addr2 u  counted->adr/len
    HEADER(XT_ICOUNT,6,"icount",DOCOLON)
        DW XT_DUP,XT_1PLUS,XT_SWAP,XT_CFETCH,XT_EXIT
