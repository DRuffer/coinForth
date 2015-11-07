; compiles a string to the dictionary. Does not add a runtime action.
        DW      link
        DB      0FEh       ; immediate
.set link = $
        DB      2,"s",','
        .align 16
XT_SCOMMA: 
	DW      DOCOLON
        DW XT_DUP,XT_TO_R,XT_CCOMMA,XT_IHERE,XT_R_FETCH,XT_DTOI
        DW XT_R_FROM,XT_IALLOT,XT_ALIGN,XT_EXIT
