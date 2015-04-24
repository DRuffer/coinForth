;C -      n1/u1 n2/u2 -- n3/u3    subtract n1-n2
        CODEHEADER(XT_MINUS,1,"-")
        MOV     @PSP+,W
        SUB     TOS,W
        MOV     W,TOS
        NEXT
