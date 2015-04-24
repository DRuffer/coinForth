;C =      x1 x2 -- flag         test x1=x2
        CODEHEADER(XT_EQUAL,1,"=")
        MOV     @PSP+,W
        SUB     TOS,W       ; x1-x2 in W, flags set
        JZ      TOSTRUE
TOSFALSE: MOV   #0,TOS
        NEXT
