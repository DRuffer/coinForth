    ; IMMED(SQUOTE,2,"S"",DOCOLON)
        DW      link
        DB      0FEh       ; immediate
.set link = $
        DB      2,'r','"'
        .align 16
XT_RQUOTE: DW      DOCOLON
        DW XT_DOLITERAL,XT_DORQUOTE,XT_COMMA
        DW XT_HERE,XT_COMMA,XT_DOLITERAL,22h,XT_PARSE
	DW XT_DUP,XT_1PLUS,XT_ALLOT, XT_SCOMMA
        DW XT_EXIT
