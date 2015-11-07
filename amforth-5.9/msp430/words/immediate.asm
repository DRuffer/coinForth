;C IMMEDIATE   --   make last def'n immediate
;   0FE LATEST @ 1- HC! ;   set Flashable immediate flag
    HEADER(IMMEDIATE,9,"immediate",DOCOLON)
        DW XT_DOLITERAL,0FEh,XT_GET_CURRENT,XT_1MINUS,XT_CSTOREI
        DW XT_EXIT
