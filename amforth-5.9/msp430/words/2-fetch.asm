;C 2@    a-addr -- x1 x2    fetch 2 cells
;   DUP CELL+ @ XT_SWAP @ ;
;   the lower address will appear on top of stack
    HEADER(XT_2FETCH,2,"2@",DOCOLON)
        DW XT_DUP,XT_CELLPLUS,XT_FETCH,XT_SWAP,XT_FETCH,XT_EXIT
