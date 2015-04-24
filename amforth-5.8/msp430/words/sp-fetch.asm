;Z SP@  -- a-addr       get data stack pointer
        CODEHEADER(XT_SP_FETCH,3,"sp@")
        SUB #2,PSP
        MOV TOS,0(PSP)
        MOV PSP,TOS
        NEXT
