;X M+       d n -- d         add single to double
        CODEHEADER(XT_MPLUS,2,"m+")
        ADD     TOS,2(PSP)
        ADDC    #0,0(PSP)
        MOV     @PSP+,TOS
        NEXT
