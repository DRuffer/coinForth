;C R>    -- x    R: x --   pop from return stack
        CODEHEADER(XT_R_FROM,2,"r>")
        SUB #2,PSP      ; 2
        MOV TOS,0(PSP)    ; 4
        MOV @RSP+,TOS
        NEXT
