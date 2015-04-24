;Z USER     n --        define user variable with offset 'n'
        HEADER(XT_USER,4,"user",DOCOLON)
        DW XT_DOCREATE,XT_COMPILE, DOUSER, XT_COMMA, XT_REVEAL,XT_EXIT
DOUSER: ; -- a-addr     ; add constant to User Pointer, result in TOS
        SUB #2,PSP
        MOV TOS,0(PSP)
        MOV @W,TOS
        ADD &UP,TOS
        NEXT

CODEHEADER(XT_UP_FETCH,3,"up@")
        SUB #2,PSP
        MOV &UP,TOS
	NEXT
