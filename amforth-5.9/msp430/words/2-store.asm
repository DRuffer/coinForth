;C 2!    x1 x2 a-addr --    store 2 cells
;   XT_SWAP OVER ! CELL+ ! ;
;   the top of stack is stored at the lower adrs
    HEADER(XT_2STORE,2,"2!",DOCOLON)
        DW XT_SWAP,XT_OVER,XT_STORE,XT_CELLPLUS,XT_STORE,XT_EXIT
