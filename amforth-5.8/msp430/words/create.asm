;C CREATE   --      create an empty definition
;   HEADER
;   DOROM ,CF              code field
    HEADER(XT_CREATE,6,"create",DOCOLON)
        DW XT_DOCREATE
        DW XT_COMPILE,DOROM
	DW XT_REVEAL
        DW XT_EXIT
