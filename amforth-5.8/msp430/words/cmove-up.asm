;X CMOVE>  c-addr1 c-addr2 u --  move from top
; as defined in the ANSI optional String word set
        CODEHEADER(XT_CMOVEUP,6,"cmove>")
        MOV     @PSP+,W     ; dest adrs
        MOV     @PSP+,X     ; src adrs
        CMP     #0,TOS
        JZ      CMOVU_X
        ADD     TOS,W       ; start at end
        ADD     TOS,X
CMOVU_1: SUB    #1,X
        SUB     #1,W
        MOV.B   @X,0(W)     ; copy byte
        SUB     #1,TOS
        JNZ     CMOVU_1
CMOVU_X: MOV    @PSP+,TOS   ; pop new TOS
        NEXT
