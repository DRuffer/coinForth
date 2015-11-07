;Z (IS")     -- c-addr u   run-time code for S"
;   R> ICOUNT 2DUP + ALIGNED >R  ;
; Harvard model, for string stored in Code space
; e.g. as used by ."
    ; HEADER(XISQUOTE,5,"(IS\")",DOCOLON)
        DW      link
        DB      0FFh       ; not immediate
.set link = $
        DB      4,"(s",'"',')'
        .align 16
XT_DOSLITERAL:
        DW DOCOLON

        DW XT_R_FROM,XT_ICOUNT,XT_2DUP,XT_PLUS,XT_ALIGNED,XT_TO_R
        DW XT_EXIT
