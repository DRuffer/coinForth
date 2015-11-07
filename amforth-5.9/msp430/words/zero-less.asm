;C 0<     n -- flag      true if TOS negative
        CODEHEADER(XT_ZEROLESS,2,"0<")
        ADD     TOS,TOS     ; set cy if TOS negative
        SUBC    TOS,TOS     ; TOS=-1 if carry was clear
        XOR     #-1,TOS     ; TOS=-1 if carry was set
        NEXT
