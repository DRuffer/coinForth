;C /MOD   n1 n2 -- n3 n4    signed divide/rem'dr
;   >R S>D R> FM/MOD ;
    HEADER(XT_SLASHMOD,4,"/mod",DOCOLON)
        DW XT_TO_R,XT_S2D,XT_R_FROM,FMSLASHMOD,XT_EXIT
