;C +!     n/u a-addr --       add cell to memory
        CODEHEADER(XT_PLUSSTORE,2,"+!")
        ADD     @PSP+,0(TOS)
        MOV     @PSP+,TOS
        NEXT
