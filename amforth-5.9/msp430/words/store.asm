;C !        x a-addr --   store cell in memory
        CODEHEADER(XT_STORE,1,"!")
        MOV     @PSP+,0(TOS)
        MOV     @PSP+,TOS
        NEXT
