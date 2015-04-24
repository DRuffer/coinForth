;Z RP@  -- a-addr       get return stack pointer
        CODEHEADER(XT_RP_FETCH,3,"rp@")
        SUB #2,PSP
        MOV TOS,0(PSP)
        MOV RSP,TOS
        NEXT
