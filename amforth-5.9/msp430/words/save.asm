; SAVE erases the first 128 bytes of Info Flash, then
; copies the User Area and subsequent RAM variables there.
        HEADER(SAVE,4,"SAVE",DOCOLON)
        DW XT_DOLITERAL,RAMINFOAREA
	DW XT_DOLITERAL,FLASHINFOAREA
	DW XT_DOLITERAL,INFO_SIZE
        DW XT_2DUP,XT_FLERASE,XT_DTOI,XT_EXIT
