;Z S=    c-addr1 c-addr2 u -- n   string compare
;Z             n<0: s1<s2, n=0: s1=s2, n>0: s1>s2
        CODEHEADER(XT_SEQUAL,2,"s=")
        MOV     @PSP+,W     ; adrs2
        MOV     @PSP+,X     ; adrs1
        CMP     #0,TOS
        JZ      SEQU_X
SEQU_1: CMP.B   @W+,0(X)    ; compare char1-char2
        JNZ     SMISMATCH
        ADD     #1,X
        SUB     #1,TOS
        JNZ     SEQU_1
        ; no mismatch found, strings are equal, TOS=0
        JMP     SEQU_X
        ; mismatch found, CY clear if borrow set (s1<s2)
SMISMATCH: SUBC TOS,TOS     ; TOS=-1 if borrow was set
        ADD     TOS,TOS     ; TOS=-2 or 0
        ADD     #1,TOS      ; TOS=-1 or +1
SEQU_X: NEXT                ; return result in TOS
