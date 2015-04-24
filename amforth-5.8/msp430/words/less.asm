;C <      n1 n2 -- flag        test n1<n2, signed
        CODEHEADER(XT_LESS,1,"<")
        MOV     @PSP+,W
        SUB     TOS,W       ; x1-x2 in W, flags set
        JGE     TOSFALSE
TOSTRUE: MOV    #-1,TOS
        NEXT
