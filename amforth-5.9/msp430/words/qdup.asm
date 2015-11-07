;C ?DUP     x -- 0 | x x    DUP if nonzero
        CODEHEADER(XT_QDUP,4,"?dup")
        CMP     #0,TOS          ; 1  test for TOS nonzero
        JNZ     PUSHTOS         ; 2
NODUP:  NEXT                    ; 4
