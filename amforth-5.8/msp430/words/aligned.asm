;C ALIGNED  addr -- a-addr       align given addr
;   DUP 1 AND + ;
        HEADER(XT_ALIGNED,7,"aligned",DOCOLON)
        DW  XT_DUP,XT_ONE,XT_AND,XT_PLUS,XT_EXIT
