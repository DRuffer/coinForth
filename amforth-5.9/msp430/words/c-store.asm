;C C!      char c-addr --    store char in memory
        CODEHEADER(XT_CSTORE,2,"c!")
        MOV     @PSP+,W
        MOV.B   W,0(TOS)
        MOV     @PSP+,TOS
        NEXT
