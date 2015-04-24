;C DROP     x --          drop top of stack
        CODEHEADER(XT_DROP,4,"drop")
        MOV     @PSP+,TOS       ; 2
        NEXT                    ; 4
