;Z SP!  a-addr --       set data stack pointer
        CODEHEADER(XT_SP_STORE,3,"sp!")
        MOV     TOS,PSP
        MOV     @PSP+,TOS       ; 2
        NEXT
