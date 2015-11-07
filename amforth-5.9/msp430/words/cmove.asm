;X CMOVE   c-addr1 c-addr2 u --  move from bottom
; as defined in the ANSI optional String word set
; On byte machines, CMOVE and CMOVE> are logical
; factors of MOVE.  They are easy to implement on
; CPUs which have a block-move instruction.
        CODEHEADER(XT_CMOVE,5,"cmove")
        MOV     @PSP+,W     ; dest adrs
        MOV     @PSP+,X     ; src adrs
        CMP     #0,TOS
        JZ      CMOVE_X
CMOVE_1: MOV.B  @X+,0(W)    ; copy byte
        ADD     #1,W
        SUB     #1,TOS
        JNZ     CMOVE_1
CMOVE_X: MOV    @PSP+,TOS   ; pop new TOS
        NEXT
