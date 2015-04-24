;C R@    -- x     R: x -- x   fetch from rtn stk
        CODEHEADER(XT_R_FETCH,2,"r@")
        SUB #2,PSP
        MOV TOS,0(PSP)
        MOV @RSP,TOS
        NEXT
