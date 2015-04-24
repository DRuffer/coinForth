;C I,    x --           append cell to Code dict
;   XT_IHERE I! 1 CELLS IALLOT ;
    ; HEADER(COMMA,2,",",DOCOLON)
        DW      link
        DB      0FFh       ; not immediate
.set link = $
        DB      1,","
        .align 16
XT_COMMA: DW      DOCOLON
        DW XT_IHERE,XT_STOREI,XT_TWO,XT_IALLOT,XT_EXIT
