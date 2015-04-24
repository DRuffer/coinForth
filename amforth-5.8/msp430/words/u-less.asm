;C U<    u1 u2 -- flag       test u1<u2, unsigned
        CODEHEADER(XT_ULESS,2,"u<")
        MOV     @PSP+,W
        SUB     TOS,W       ; u1-u2 in W, cy clear if borrow
        JNC     TOSTRUE
        JMP     TOSFALSE
