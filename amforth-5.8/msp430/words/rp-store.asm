;Z RP!  a-addr --       set return stack pointer
        CODEHEADER(XT_RP_STORE,3,"rp!")
        MOV     TOS,RSP
        MOV     @PSP+,TOS       ; 2
        NEXT
