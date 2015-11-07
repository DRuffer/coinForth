;C EXIT     --            exit a colon definition
        CODEHEADER(XT_EXIT,4,"exit")
        MOV @RSP+,IP    ; 2 pop old IP from return stack
        NEXT            ; 4
