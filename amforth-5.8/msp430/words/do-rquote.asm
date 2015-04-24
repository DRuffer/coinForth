;Z (S")     -- c-addr u   run-time code for S"
;   R@ I@                     get Data address
;   R> CELL+ DUP IC@ CHAR+    -- Dadr Radr+2 n+1
;   2DUP + ALIGNED >R         -- Dadr Iadr n+1
;   >R OVER R> I->D           -- Dadr
;   COUNT ;
; Harvard model, for string stored in Code space
; which is copied to Data space.
    ; HEADER(XSQUOTE,4,"(S")",DOCOLON)
        DW      link
        DB      0FFh       ; not immediate
.set link = $
        DB      4,"(r",'"',')'
        .align 16
XT_DORQUOTE: DW      DOCOLON
        DW XT_R_FETCH,XT_FETCHI
        DW XT_R_FROM,XT_CELLPLUS,XT_DUP,XT_CFETCHI,XT_1PLUS
        DW XT_2DUP,XT_PLUS,XT_ALIGNED,XT_TO_R
        DW XT_TO_R,XT_OVER,XT_R_FROM,XT_ITOD,XT_ICOUNT,XT_EXIT
