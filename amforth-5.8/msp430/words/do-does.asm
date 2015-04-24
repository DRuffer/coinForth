;Z (DOES>)  --      run-time action of DOES>
;   R>              adrs of headless DOES> def'n
;   GET-CURRENT NFA>CFA    code field to fix up
;   !CF ;
    ; HEADER(XDOES,7,"(DOES>)",DOCOLON)
        DW      link
        DB      0FFh       ; not immediate
.set link = $
        DB      7,"(does>)"
        .align 16
XT_DODOES: DW      DOCOLON
        DW XT_R_FROM,XT_GET_CURRENT,XT_NFA2CFA,XT_STOREI
        DW XT_EXIT
