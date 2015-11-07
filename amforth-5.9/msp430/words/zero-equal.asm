;C 0=     n/u -- flag    return true if TOS=0
        CODEHEADER(XT_ZEROEQUAL,2,"0=")
        SUB     #1,TOS      ; borrow (clear cy) if TOS was 0
        SUBC    TOS,TOS     ; TOS=-1 if borrow was set
        NEXT
